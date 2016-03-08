module Mu
  module Logging
    module Formatting
      def self.colored_format
        ColoredLogFormatter.method(:format_log)
      end
    end

    class ColoredLogFormatter
      def self.format_log(_severity, datetime, _progname, data)
        event    = data.delete('event')    || data.delete(:event)
        duration = data.delete('duration') || data.delete(:duration)
        sql      = data.delete('sql')      || data.delete(:sql)

        str = [
          "\e[35m[#{datetime.strftime('%T.%L')}]\e[0m",                 # magenta
          "\e[32m#{event}\e[0m",                                        # green
          data.map { |k, v| ["\e[34m#{k}\e[0m", v].join('=') }.join(' ') # blue=white
        ].join(' ')
        str << " \e[31m(#{duration.to_f.round(2)}ms)\e[0m" if duration # red
        str << "\n" << sql if sql
        str << "\n"
      end
    end
  end
end
