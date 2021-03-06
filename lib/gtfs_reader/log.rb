require 'log4r'
require 'log4r/formatter/patternformatter'
require 'colorize'

module GtfsReader
  module Log
    class << self
      def debug(*args, &block); log :debug, *args, &block end
      def  info(*args, &block); log :info,  *args, &block end
      def  warn(*args, &block); log :warn,  *args, &block end
      def error(*args, &block); log :error, *args, &block end
      def fatal(*args, &block); log :fatal, *args, &block end

      def log(level, *args, &block)
        logger.send level, *args, &block
        nil
      end

      def logger
        @logger = yield if block_given?
        @logger ||= create_logger
      end

      def level=(lev)
        logger.level =
            case lev
            when :debug then logger.levels.index 'DEBUG'
            when :info  then logger.levels.index 'INFO'
            when :warn  then logger.levels.index 'WARN'
            when :error then logger.levels.index 'ERROR'
            when :fatal then logger.levels.index 'FATAL'
            else raise "unknown log level '#{lev}'"
            end
      end

      def level
        logger.level
      end

      # Silence the logger for the duration of the given block
      def quiet
        old_logger = @logger
        begin
          @logger = NoOpLogger.new
          yield
        ensure
          @logger = old_logger
        end
      end

      private

      def create_logger
        Log4r::Logger.new('GtfsReader').tap do |log|
          out = Log4r::StdoutOutputter.new('log_stdout')
          out.formatter = Log4r::PatternFormatter.new pattern: '%d [%l]: %m'
          log.outputters << out
          log.level = Log4r::INFO
          log.debug { 'Starting GtfsReader...'.underline.colorize :yellow }
        end
      end
    end

    class NoOpLogger
      def method_missing(*args, &block)
        nil
      end
    end
  end
end
