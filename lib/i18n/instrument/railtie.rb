module I18n
  module Instrument
    class Railtie < Rails::Railtie
      initializer 'i18n.instrument.middleware' do |app|
        app.middleware.use(I18n::Instrument::Middleware)
      end
    end
  end
end
