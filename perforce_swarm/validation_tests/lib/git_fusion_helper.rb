require_relative 'log'

class GitFusionHelper
  def initialize(p4port, user, password)
    @user     = user
    @password = password
    @p4port   = p4port
  end

  # depot_path should not include trailing /...
  def make_new_gf_repo(gf_repo_name, depot_path)
    LOG.log("Making new gf repo #{gf_repo_name} at #{@p4port}")
    Dir.mktmpdir('GFHelper-', tmp_client_dir) do |local_workspace|
      path = local_workspace + '/p4gf_config'
      begin
        p4 = P4Helper.new(@p4port, @user, @password, local_workspace, "//.git-fusion/repos/#{gf_repo_name}/...")
        p4.connect_and_sync
        raise "Config file already exists for GF repo #{gf_repo_name}" if File.exist?(path)
        File.write(path, gf_config_contents(depot_path))
        p4.add(path)
        p4.submit
      ensure
        p4.disconnect if p4
      end
    end
  end

  def apply_gf_global_config(properties_hash)
    LOG.log("Applying new gf config #{properties_hash.inspect} at #{@p4port}")
    Dir.mktmpdir('GFHelper-', tmp_client_dir) do |local_workspace|
      file = File.join(local_workspace, 'p4gf_config')
      begin
        p4 = P4Helper.new(@p4port, @user, @password, local_workspace, '//.git-fusion/...')
        p4.connect
        p4.sync(file)
        content = File.read(file)
        properties_hash.each do |name, value|
          regex = /^#{name}[ =].*$/
          raise "property not found in p4gf_config file : #{name}" unless content =~ regex
          content.gsub!(regex, "#{name} = #{value}")
        end
        p4.edit(file)
        File.write(file, content)
        p4.submit
      ensure
        p4.disconnect if p4
      end
    end
  end

  private

  def gf_config_contents(depot_path)
    # This could be enhanced in future if we need to change some settings in the config
    ['[@repo]',
     'description = Repo created by GitSwarm test automation',
     'enable-git-submodules = yes',
     'enable-git-merge-commits = yes',
     'enable-git-branch-creation = yes',
     "depot-branch-creation-depot-path = #{depot_path}/{git_branch_name}",
     'depot-branch-creation-enable = all',
     '[master]',
     "view = #{depot_path}/master/... ...",
     'git-branch-name = master',
     ''
    ].join("\n")
  end
end
