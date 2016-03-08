module Mu
  module Logging
    module Formatting
      def self.json_format
        JsonLogFormatter.method(:format_log)
      end
    end

    class JsonLogFormatter
      def self.format_log(_severity, datetime, _progname, data)
        json = {
          '@timestamp' => datetime.iso8601(3),
          app: Mu.app,
          environment: Mu.env,
          host: hostname,
          event: data.delete('event') || data.delete(:event)
        }.merge(data)
        JSON.generate(json) + "\n"
      end

      def self.hostname
        @hostname ||= Socket.gethostname
      end
    end
  end
end
