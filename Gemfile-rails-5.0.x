source 'https://rubygems.org'

gemspec


group :development do
  gem 'pry-byebug'
end

group :development, :test do
  gem 'rails', '~> 5.0', '<= 5.0.7.2'
  gem 'rspec'
  gem 'rspec-rails'
end
