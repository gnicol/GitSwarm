class CONFIG
  P4_PORT                = 'p4_port'
  P4_USER                = 'p4_user'
  P4_PASSWORD            = 'p4_password'
  P4_DEPOT_ROOT          = 'p4_gitswarm_depot_root'
  GS_URL                 = 'gitswarm_url'
  GS_USER                = 'gitswarm_username'
  GS_PASSWORD            = 'gitswarm_password'
  SECURE_GF              = 'secure_git_fusion'
  SECURE_GF_DEPOT_ROOT   = 'secure_git_fusion_depot_root'
  RUN_ID                 = 'run_id' # static run_id for test development (enforce_permissions_spec)
  SKIP_SETUP             = 'skip_setup' # skip setup for test development (enforce_permissions_spec)
  SKIP_TEARDOWN          = 'skip_teardown' # skip teardown for test development (enforce_permissions_spec)

  @config                = nil

  # One time only
  unless @config
    # Load Config
    LOG.info('Loading config...')
    @config = YAML.load_file('config.yml')
    LOG.info @config
    LOG.level(@config['log_level']) if @config['log_level']
  end

  def self.get(property)
    @config[property]
  end

  def self.set(property, value)
    @config[property] = value
  end
end
