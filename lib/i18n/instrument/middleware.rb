require 'i18n/debug'
require 'request_store'

module I18n
  module Instrument
    class Middleware
      # used to store request information in the request store
      STORE_KEY = :i18n_instrumentation

      # canned response sent to js instrumentation requests
      JS_RESPONSE = [
        200, {
          'Content-Type' => 'application/json',
          'Content-Length' => 2
        }, [
          '{}'
        ]
      ]

      def initialize(app)
        @app = app

        # this will fire on every call to I18n.t
        I18n::Debug.on_lookup do |key, value|
          next unless enabled?
          config.on_lookup.call(key, value)

          begin
            # find the first application-specific line in the stack trace
            raw_trace = filter_stack_trace(::Kernel.caller)
            trace = raw_trace.split(":in `").first if raw_trace

            # grab path params (set in `call` method below)
            url = store.fetch(STORE_KEY, {}).fetch(:url, nil)

            if url.present? && trace.present?
              record_translation_lookup(
                url: url, trace: trace, key: key,
                locale: I18n.locale.to_s, source: 'ruby'
              )
            end
          rescue => e
            config.on_error.call(e)
          end
        end
      end

      def call(env)
        if i18n_js_request?(env)
          handle_i18n_js_request(env)
        else
          handle_regular_request(env)
        end
      rescue => e
        config.on_error.call(e)
        @app.call(env)
      end

      private

      def filter_stack_trace(trace)
        trace.find { |line| line.start_with?(config.stack_trace_prefix) }
      end

      def record_translation_lookup(url:, trace:, key:, locale:, source:)
        config.on_record.call({
          url: url, trace: trace, key: key,
          source: source, locale: locale
        })
      end

      def handle_regular_request(env)
        return @app.call(env) unless enabled?

        # store params from env in request storage so they can be used in the
        # I18n on_lookup callback above
        store[STORE_KEY] = { url: env['REQUEST_URI'] }

        @app.call(env)
      end

      def handle_i18n_js_request(env)
        return JS_RESPONSE unless enabled?

        body = JSON.parse(env['rack.input'].read)
        url = body['url']
        key = body['key']
        locale = body['locale']

        if url.present? && key.present?
          record_translation_lookup(
            url: url, trace: nil, key: key,
            locale: locale, source: 'javascript'
          )
        end

        JS_RESPONSE
      end

      def i18n_js_request?(env)
        env.fetch('REQUEST_URI', '').include?(js_endpoint) &&
          env.fetch('REQUEST_METHOD', '').upcase == 'POST'
      end

      def config
        I18n::Instrument.config
      end

      def js_endpoint
        config.js_endpoint
      end

      def enabled?
        config.enabled?
      end

      def store
        RequestStore.store
      end
    end
  end
end
