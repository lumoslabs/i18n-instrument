module I18n
  module Instrument
    class DummyApplication < ::Rails::Application
      config.eager_load = false
      config.assets.enabled = true
      config.assets.compile = true
      config.assets.allow_debugging = true
      config.assets.digest = true
      config.active_support.deprecation = :stderr
    end
  end
end
