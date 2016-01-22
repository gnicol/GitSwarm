require 'P4'
require_relative 'log'
#
# Copes with unicode and ssl servers.
# Auto-detects based on p4port and post connection inquiry
#
class P4Helper
  attr_reader :p4
  attr_accessor :client_name

  def initialize(p4port, user, password, local_dir = nil, depot_path = nil)
    # Pointing the p4 environment variables to tmp-clients directory
    p4_home = tmp_client_dir
    ENV['P4ENVIRO']  = File.join(p4_home, '.p4enviro')
    ENV['P4TICKETS'] = File.join(p4_home, '.p4tickets')
    ENV['P4TRUST']   = File.join(p4_home, '.p4trust')

    @user = user
    @password = password
    @local_dir = local_dir
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

    @p4.run_login
  end

  def connect_and_sync
    connect
    spec = @p4.fetch_client
    spec['Root'] = @local_dir
    spec['View'] = [@depot_path + ' //'+client_name+'/...']
    @p4.save_client(spec)
    sync
  end

  def sync
    LOG.debug 'Syncing from ' + @depot_path + ' into ' + @local_dir
    @p4.run_sync('-f', '-q') # -q to stop it throwing a warning if no files exist under the depot path
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

  def last_commit_message(file)
    LOG.debug 'Getting last commit message for file ' + file
    output = @p4.run_changes('-l', '-m', '1', file)
    output.first
  end

  def disconnect
    LOG.debug 'Disconnecting from p4d'
    @p4.run_client('-d', client_name)
    @p4.run_logout
    @p4.run_trust('-d') if @p4.port.start_with?('ssl')
    @p4.disconnect
  end
end
