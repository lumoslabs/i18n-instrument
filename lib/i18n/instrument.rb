require 'i18n/instrument/railtie'

module I18n
  module Instrument
    autoload :Configurator, 'i18n/instrument/configurator'
    autoload :Middleware,   'i18n/instrument/middleware'

    class << self
      attr_reader :config

      def configure
        @config = Configurator.new
        yield @config if block_given?
      end
    end
  end

  # set default config
  Instrument.configure
end
