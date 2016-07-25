# encoding: UTF-8

$:.push(File.dirname(__FILE__))

require 'pry-byebug'

require 'rails'
require 'action_controller/railtie'
require 'action_view/railtie'

require 'rspec'
require 'rspec/rails'

ENV['RAILS_ENV'] ||= 'test'

require 'i18n/instrument'

Dir.chdir('spec') do
  require File.expand_path('../config/application', __FILE__)
  I18n::Instrument::DummyApplication.initialize!
end
