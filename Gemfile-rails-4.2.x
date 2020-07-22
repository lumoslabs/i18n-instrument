source 'https://rubygems.org'

gemspec

group :development do
  gem 'pry-byebug'
end

group :development, :test do
  gem 'rails', '~> 4.2', '<= 4.2.11.3'
  gem 'rspec'
  gem 'rspec-rails'
end
