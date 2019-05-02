source 'https://rubygems.org'

gemspec

group :development do
  gem 'pry-byebug'
end

group :development, :test do
  gem 'rspec'
  gem 'rspec-rails'

  if ENV['RAILS_VERSION']
    gem 'rails', "~> #{ENV['RAILS_VERSION']}"
  else
    gem 'rails', '~> 5.0'
  end
end
