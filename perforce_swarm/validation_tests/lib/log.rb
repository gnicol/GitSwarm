require 'logger'

#
# Class that splits log output so it goes to stdout and a file
#

class MultiIO
  def initialize(*targets)
    @targets = targets
  end

  def write(*args)
    @targets.each { |t| t.write(*args) }
  end

  def close
    @targets.each(&:close)
  end
end

class LOG
  @internal_log = nil

  unless @internal_log
    # log which uses Log to split output to stdout and file
    logfile = Dir.pwd + File::SEPARATOR + 'validation_test.log'
    puts logfile
    File.delete(logfile) if File.exist?(logfile)
    @internal_log ||= Logger.new MultiIO.new(STDOUT, File.open(logfile, 'a'))
    @internal_log.info('Logging to ' + logfile)
    @internal_log.level = Logger::INFO # set default log level to info
  end

  def self.level(level)
    if level=='INFO'
      @internal_log.level = Logger::INFO
    elsif level=='DEBUG'
      @internal_log.level = Logger::DEBUG
    else
      raise 'Unknown log level supplied : ' + level
    end
    @internal_log.info("Log level set to #{level}")
  end

  def self.info(message)
    @internal_log.info message
  end

  def self.log(message)
    @internal_log.info message
  end

  def self.debug(message)
    @internal_log.debug message
  end
end
