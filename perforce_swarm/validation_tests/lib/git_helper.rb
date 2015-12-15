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
  # factory method for creating HTTP/S helpers
  def self.http_helper(local_dir, http_url, user, password, email)
    helper     = new(local_dir, user, email)
    url        = URI(http_url)

    # now add the username and password into the url
    helper.url = url.scheme + '://' + user + ':' + password + '@' + url.host + url.path
    helper
  end
  

  # TODO: define an ssh_helper factory method, including accepting the host key
  # For ssh, adding a key in just the contect of a command use:
  # command = 'ssh-agent bash -c 'ssh-add '+private_key+'; git clone '+url_ssh+'\''
  # system (command)

  attr_accessor :url, :git, :fail_on_error # throw exceptions if any system calls return non-0
  
  def initialize(local_dir, user, email)
    # the binary to call, defaulting to whatever is on the path
    @git            = CONFIG.get('git_binary') || 'git'
    @local_dir_path = local_dir

    Dir.mkdir(@local_dir_path) unless Dir.exist?(@local_dir_path)
    @user           = user
    @email          = email
    @current_branch = 'master'
    @fail_on_error = true
  end

  def clone
    LOG.debug("Cloning from #{@url} into #{@local_dir_path}")
    success = call_system([@git, 'clone', @url, @local_dir_path])
    if success
      Dir.chdir(@local_dir_path) do
        call_system([@git, 'config', 'user.name', @user])
        call_system([@git, 'config', 'user.email', @email])
      end
    end
    success
  end

  # Adds everything under the git repo
  def add
    run_git_command('add', '.')
  end

  def commit(message = 'auto_message')
    run_git_command('commit', '-m', '"' + message + '"')
  end

  def add_commit_push
    add && commit && push
  end

  def add_commit_push(message = 'auto_message')
    add
    commit(message)
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
    success = run_git_command('checkout', branchname)
    @current_branch = branchname if success
    success
  end

  def branch_and_checkout(branchname)
    branch(branchname) && checkout(branchname)
  end

  def checkout_and_pull(branchname)
    checkout(branchname) && pull
  end

  private

  def run_git_command(*args)
    command = Shellwords.join([@git, *args])
    LOG.debug("Running #{command}")
    success = false
    Dir.chdir(@local_dir_path) do
      success = call_system(command)
    end
    success
  end

  # utility to call the system command and fail if it is not successful and error_on_fail is enabled (default on)
  def call_system(command)
    LOG.debug(command)
    command = Shellwords.join(command) if command.is_a?(Array)
    success = system(command)
    fail "system command failed: #{command}" if !success && @fail_on_error
    success
  end
end
