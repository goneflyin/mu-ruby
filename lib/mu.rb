require 'mu/version'
require 'mu/logger'
require 'dotenv'

module Mu
  def self.app
    @_app ||= 'application'
  end

  def self.app=(application_name)
    @_app = application_name
  end

  def self.env
    @_env ||= ENV['RACK_ENV'] || 'development'
  end

  def self.env=(environment)
    @_env = environment
  end

  def self.logger
    @_logger ||= Mu::Logger.new(STDOUT)
  end

  def self.logger=(logger)
    @_logger = logger
  end

  def self.report_error(_e)
    # TODO: Add call to abstraction for reporting service
    raise NotImplementedError, 'Abstraction for reporting errors not yet implemented.'
  end

  def self.report_error!(_e)
    # TODO: Add call to abstraction for reporting service
    raise NotImplementedError, 'Abstraction for reporting errors not yet implemented.'
  end

  def self.init(app = nil)
    self.app = app if app

    # Dotenv gives precedence to files loaded earlier in the list
    Dotenv.load("#{Mu.env}.env", '.env')
  end
end

MU = Mu unless defined?(MU)
