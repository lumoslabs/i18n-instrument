$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'i18n/instrument/version'

Gem::Specification.new do |s|
  s.name     = 'i18n-instrument'
  s.version  = ::I18n::Instrument::VERSION
  s.authors  = ['Cameron Dutro']
  s.email    = ['camertron@gmail.com']
  s.homepage = 'https://github.com/lumoslabs/i18n-instrument'

  s.description = s.summary = 'Instrument calls to I18n.t in Ruby and JavaScript.'

  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true

  s.add_dependency 'i18n-debug', '~> 1.0'

  if ENV['RAILS_VERSION']
    s.add_dependency 'railties', "~> #{ENV['RAILS_VERSION']}"
  else
    s.add_dependency 'railties', '~> 4.0'
  end

  s.add_dependency 'request_store', '~> 1.0'

  s.require_path = 'lib'
  s.files = Dir['{lib,spec}/**/*', 'README.md', 'i18n-instrument.gemspec', 'LICENSE']
end
