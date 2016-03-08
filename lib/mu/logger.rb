require 'json'
require 'logger'
require 'socket'
require 'mu/logging/colored_log_formatter'
require 'mu/logging/json_log_formatter'

VALID_RUBY_CONST = /\A[A-Z][a-zA-Z_]*\Z/

module Mu
  class Logger
    LEVELS = %w(debug info warn error fatal).freeze

    LEVELS.each do |method|
      define_method(method.to_sym) do |event, data = {}, &block|
        log_event(method.to_sym, event, data, &block)
      end
    end

    def initialize(*args)
      @logger = create_logger(args)

      @logger.formatter =
        if ['colored'].include?(ENV['LOG_FORMAT'])
        then Mu::Logging::Formatting.colored_format
        else Mu::Logging::Formatting.json_format
        end

      self.level = LEVELS.index(ENV['LOG_LEVEL']) || ::Logger::INFO
    end

    def for_event(event)
      RubyCompatibleLogger.new(event, @logger)
    end

    private

    def create_logger(args)
      return ::Logger.new(STDOUT)                    if args.empty? # Default to STDOUT
      return args[0]                                 if logger?(args[0])
      return ::Logger.new(Kernel.const_get(args[0])) if const_io_stream?(args[0])

      ::Logger.new(*args)
    end

    def logger?(logger_param)
      # Allow use of pre-existing Logger
      logger_param.is_a?(::Logger)
    end

    # Allow STDOUT or STDERR to be explicitly specified
    def const_io_stream?(logger_param)
      logger_param.is_a?(String) &&
        logger_param =~ VALID_RUBY_CONST &&
        Kernel.const_defined?(logger_param)
    end

    def log_event(method, event, data = {})
      extra = { 'event' => event }
      data.is_a?(Hash) ? extra.merge!(data) : extra['message'] = data

      if block_given?
        t0 = now
        begin
          yield(extra)
        rescue Exception => e
          extra['exception'] = [e.class.name, e.message]
          raise
        ensure
          extra['duration'] = (now - t0)
          @logger.send(method, prefix_and_flatten_hash(extra))
        end
      else
        @logger.send(method, prefix_and_flatten_hash(extra))
      end
    end

    def method_missing(meth, *args, &block)
      @logger.send(meth, *args, &block)
    end

    def now
      Time.now.to_f * 1000
    end

    MAX_NESTED_LEVELS = 7

    def prefix_and_flatten_hash(hash, prefix = '', level = 1)
      if level > MAX_NESTED_LEVELS
        return { "#{prefix}TRUNCATED" => "data nested deeper than #{MAX_NESTED_LEVELS} levels has been truncated" }
      end

      hash.inject({}) do |ret, (k, v)|
        key = prefix + k.to_s
        if v && v.is_a?(Hash)
        then ret.merge(prefix_and_flatten_hash(v, key + '.', level + 1))
        else ret.merge(key => v)
        end
      end
    end

    class RubyCompatibleLogger < Mu::Logger
      LEVELS.each do |method|
        define_method(method.to_sym) do |data = {}, &block|
          log_event(method.to_sym, @event, data, &block)
        end
      end

      def initialize(event, logger)
        @event = event
        super logger
      end
    end
  end
end
