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
    @local_dir_path = local_dir
    Dir.mkdir @local_dir_path unless Dir.exist?(@local_dir_path)
    @user = user
    @email = email
    @current_branch = 'master'
  end

  def clone
    LOG.debug 'Cloning from ' + @url + ' into ' + @local_dir_path
    call_system(@git + ' clone ' + @url + ' ' + @local_dir_path)
    Dir.chdir(@local_dir_path) do
      call_system(@git + ' config user.name ' + @user)
      call_system(@git + ' config user.email ' + @email)
    end
  end

  # Adds everything under the git repo
  def add
    run_git_command('add', '.')
  end

  def commit
    run_git_command('commit', '-m', 'auto_message')
  end

  def add_commit_push
    add
    commit
    push
  end

  def pull
    run_git_command('pull', 'origin', @current_branch)
  end

  def push
    run_git_command('push', 'origin', @current_branch)
  end

  def branch(branchname)
    run_git_command('branch', branchname)
  end

  def checkout(branchname)
    run_git_command('checkout', branchname)
    @current_branch = branchname
  end

  def branch_and_checkout(branchname)
    branch(branchname)
    checkout(branchname)
  end

  def checkout_and_pull(branchname)
    checkout(branchname)
    pull
  end

  private

  def run_git_command(*args)
    command = [@git, *args].join(' ')
    LOG.debug("Running #{command}")
    Dir.chdir(@local_dir_path) do
      call_system(command)
    end
  end

  # utility to call the system command and fail if it is not successful
  def call_system(command)
    fail 'system command failed: ' + command unless system(command)
  end
end
