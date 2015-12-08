require_relative 'log'

class GitFusionHelper
  def initialize(p4port, user, password)
    @user = user
    @password = password
    @p4port = p4port
  end

  def make_new_gf_repo(gf_repo_name, depot_path)
    LOG.log("Making new gf repo #{gf_repo_name} at #{@p4port}")
    local_workspace =  Dir.mktmpdir
    path = local_workspace+'/p4gf_config'
    begin
      p4 = P4Helper.new(@p4port, @user, @password, local_workspace, "//.git-fusion/repos/#{gf_repo_name}/...")
      p4.connect_and_sync
      fail("Config file already exists for GF repo #{gf_repo_name}") if File.exist?(path)
      new_file = File.open(path, 'w+')
      new_file.write gf_config_contents(depot_path)
      new_file.close

      p4.add(path)
      p4.submit
    ensure
      p4.disconnect if p4
      FileUtils.rm_r(local_workspace)
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
     'change-owner = author',
     'ignore-author-permissions = no',
     'read-permission-check = yes',
     '[master]',
     "view = #{depot_path}/master/... ...",
     'git-branch-name = master',
     ''
    ].join("\n")
  end
end
