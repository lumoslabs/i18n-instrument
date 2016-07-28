module I18n
  module Instrument
    class Configurator
      DEFAULT_ENABLED_FILE = File.join('config', 'enable_i18n_instrumentation')
      DEFAULT_JS_ENDPOINT = '/i18n/instrument.json'

      attr_accessor :js_endpoint, :stack_trace_prefix

      def initialize
        @js_endpoint = DEFAULT_JS_ENDPOINT
        @stack_trace_prefix = Rails.root.to_s

        @on_check_enabled_proc = -> do
          Rails.root.join(DEFAULT_ENABLED_FILE).exist?
        end

        @on_error_proc = ->(e) { raise e }
        @on_record_proc = ->(*) { }
        @on_lookup_proc = ->(*) { }
      end

      def on_lookup(&block)
        return @on_lookup_proc unless block
        @on_lookup_proc = block
      end

      def on_record(&block)
        return @on_record_proc unless block
        @on_record_proc = block
      end

      def on_error(&block)
        return @on_error_proc unless block
        @on_error_proc = block
      end

      def on_check_enabled(&block)
        return @on_check_enabled_proc unless block
        @on_check_enabled_proc = block
      end

      def enabled?
        @on_check_enabled_proc.call
      end
    end
  end
end
