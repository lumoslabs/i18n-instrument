source 'https://rubygems.org'

gemspec

group :development do
  gem 'pry-byebug'
end

group :development, :test do
  gem 'rails', '~> 5.2', '< 6.0'
  gem 'rspec'
  gem 'rspec-rails'
end
