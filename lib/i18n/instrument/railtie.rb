module I18n
  module Instrument
    class Railtie < Rails::Railtie
      initializer 'i18n.instrument.middleware' do |app|
        app.config.assets.paths << File.expand_path('../../../assets/javascripts', __FILE__)
        app.middleware.use(I18n::Instrument::Middleware)
      end
    end
  end
end
