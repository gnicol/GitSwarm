require 'P4'
require_relative 'log'
#
# Copes with unicode and ssl servers.
# Auto-detects based on p4port and post connection inquiry
#
class P4Helper
  attr_reader :p4
  attr_accessor :client_name

  def initialize(p4port, user, password, local_dir, depot_path)
    fail("depot_path must end in /... : #{depot_path}") unless depot_path.end_with?('/...')

    # Pointing the p4 environment variables to tmp-clients directory
    p4_home = tmp_client_dir
    ENV['P4ENVIRO'] = File.join(p4_home, '.p4enviro')
    ENV['P4TICKETS'] = File.join(p4_home, '.p4tickets')
    ENV['P4TRUST'] = File.join(p4_home, '.p4trust')

    @user = user
    @password = password
    @local_dir = local_dir.chomp('/')
    @depot_path = depot_path
    @p4 = P4.new
    @p4.port = p4port
    @p4.user = user
    @p4.password = password
    @client_name = Time.new.strftime('%y%m%d-%H%M%S%L')
  end

  def connect
    LOG.debug 'Connecting to ' + @p4.port
    @p4.client = @client_name
    @p4.connect

    if @p4.port.start_with?('ssl')
      # force we may be trusting something we trusted before and the fingerprint has changed
      @p4.at_exception_level(P4::RAISE_NONE) { @p4.run_trust('-f', '-y') }
      @p4.disconnect # if we needed to trust, we need to reconnect to get unicode info
      @p4.connect
    end

    LOG.debug 'unicode = ' + @p4.server_unicode?.inspect
    @p4.charset='utf8' if @p4.server_unicode?

    LOG.debug 'Logging in p4 user ' + @p4.user
    @p4.run_login
    spec = @p4.fetch_client
    spec['Root'] = @local_dir
    spec['View'] = [@depot_path + ' //'+client_name+'/...']
    @p4.save_client(spec)
  end

  def connect_and_sync
    connect
    sync
  end

  def sync(file = nil)
    LOG.debug("Syncing #{file} from #{@depot_path} into #{@local_dir}")
    file = File.join(@local_dir, file) if file && !file.start_with?(@local_dir) && !file.empty?
    # -q to stop it throwing a warning if no files exist under the depot path
    if file
      @p4.run_sync('-f', '-q', file)
    else
      @p4.run_sync('-f', '-q')
    end
  end

  def add(path)
    @p4.run_add(path)
  end

  def edit(path)
    @p4.run_edit(path)
  end

  def submit
    LOG.debug 'Submitting to p4d'
    @p4.run_submit('-d', 'auto description')
  end

  def connected?
    @p4 && @p4.connected?
  end

  def last_commit_message(file)
    LOG.debug 'Getting last commit message for file ' + file
    output = @p4.run_changes('-l', '-m', '1', file)
    output.first
  end

  def disconnect
    return unless connected?
    LOG.debug 'Disconnecting from p4d'
    @p4.run_client('-d', client_name)
    @p4.run_trust('-d') if @p4.port.start_with?('ssl')
    @p4.run_logout
    @p4.disconnect
  end

  def create_user(username, password, email)
    LOG.debug("Creating p4 user #{username}")
    spec = @p4.fetch_user(username)
    spec['Email'] = email
    @p4.input = spec
    @p4.run_user('-i', '-f')

    @p4.input = password
    @p4.run_passwd(username)
  end

  def user_exists?(username)
    @p4.at_exception_level(P4::RAISE_NONE) do
      result = @p4.run_users(username)
      return result.length>0
    end
    false
  end

  def delete_user(username)
    return unless user_exists?(username)
    LOG.debug("Deleting p4 user #{username}")
    @p4.run_user('-d', '-f', username)
  end

  def add_read_protects(user, depot_path)
    add_protection('read', user, depot_path)
  end

  def add_write_protects(user, depot_path)
    add_protection('write', user, depot_path)
  end

  def remove_protects(user)
    spec = @p4.fetch_protect
    spec['Protections'].delete_if { |line| line.split[2]==user }
    @p4.save_protect(spec)
  end

  # To get the current state of protects that can be later set
  def protects
    @p4.fetch_protect
  end

  # To set the entire state of protects
  def protects=(spec)
    LOG.debug('Protects are now:')
    LOG.debug(spec.inspect)
    @p4.save_protect(spec)
  end

  private

  def add_protection(level, user, depot_path)
    LOG.debug("Adding #{level} protects for #{user} to #{depot_path}")
    spec = @p4.fetch_protect
    spec['Protections'].unshift("#{level} user #{user} * #{depot_path}")
    @p4.save_protect(spec)
  end
end
