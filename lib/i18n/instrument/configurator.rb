module I18n
  module Instrument
    class Configurator
      DEFAULT_ENABLED_FILE = 'config/enable_i18n_instrumentation.txt'
      DEFAULT_JS_ENDPOINT = '/i18n/instrument.json'

      attr_accessor :js_endpoint, :stack_trace_prefix

      def initialize
        @js_endpoint = DEFAULT_JS_ENDPOINT
        @stack_trace_prefix = Rails.root.to_s

        @on_check_enabled_proc = -> do
          Rails.root.join('config', 'enable_i18n_instrumentation.txt').exist?
        end

        @on_error_proc = ->(e) { raise e }
        @on_record_proc = ->(*) { }
        @on_lookup_proc = ->(*) { }
      end

      def on_lookup(&block)
        block ? @on_lookup_proc = block : @on_lookup_proc
      end

      def on_record(&block)
        block ? @on_record_proc = block : @on_record_proc
      end

      def on_error(&block)
        block ? @on_error_proc = block : @on_error_proc
      end

      def on_check_enabled(&block)
        block ? @on_check_enabled_proc = block : @on_check_enabled_proc
      end

      def enabled?
        @on_check_enabled_proc.call
      end
    end
  end
end
