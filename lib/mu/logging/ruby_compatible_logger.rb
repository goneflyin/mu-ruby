require 'mu/logger'

module Mu
  module Logging
    class RubyCompatibleLogger < Mu::Logger
      LEVELS.each do |method|
        define_method(method.to_sym) do |data={}, &block|
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
