class CONFIG
  @config = nil

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