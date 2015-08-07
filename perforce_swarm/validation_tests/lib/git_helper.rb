require_relative 'log'
# Example usage
#
# git = GitHelper.http_helper(dir, url_http, user, password, email)
# git.clone
# # add some new files
# git.add
# git.commit
# git.push
#
#

class GitHelper
  class << self
    def http_helper(local_dir, http_url, user, password, email)
      helper = new(local_dir, user, email)
      u = URI(http_url) # now add the username and password into the url
      helper.url = u.scheme + '://' + user + ':' + password + '@' + u.host + u.path
      helper
    end
    # def ssh_helper(local_dir, ssh_url, user, ssh_key, email)
    # TODO
    # modify the @git to have the ssh_agent stuff in
    #
    # For ssh, adding a key in just the contect of a command use:
    # command = 'ssh-agent bash -c 'ssh-add '+private_key+'; git clone '+url_ssh+'\''
    # system (command)
    #
    # Also, accept the host key
    #
    # end
  end
  attr_accessor :url
  attr_accessor :git

  def initialize(local_dir, user, email)
    @git = CONFIG.get('git_binary') || 'git' # the binary to call, defaulting to whatever is on the path
    @dir = local_dir
    Dir.mkdir @dir unless Dir.exist?(@dir)
    @user = user
    @email = email
  end

  def clone
    LOG.debug 'Cloning from ' + @url + ' into ' + @dir
    system(@git + ' clone ' + @url + ' ' + @dir)
    Dir.chdir(@dir) do
      system(@git + ' config user.name ' + @user)
      system(@git + ' config user.email ' + @email)
    end
  end

  # Adds everything under the git repo
  def add
    Dir.chdir(@dir) { system(@git + ' add .') }
  end

  def commit
    Dir.chdir(@dir) { system(@git +' commit -m auto_message') }
  end

  def push
    LOG.debug 'Pushing to ' +@url
    Dir.chdir(@dir) { system(@git + ' push') }
  end

  def add_commit_push
    add
    commit
    push
  end

  def pull
    LOG.debug 'pulling from ' +@url
    Dir.chdir(@dir) { system(@git + ' pull ' + @url) }
  end
end
