source 'https://rubygems.org'
gemspec

group :development, :test do
  gem 'rake'
  gem 'rspec'
  gem 'cucumber'
end

group :debug do
  gem 'debug', '>= 1.0.0', require: false, platforms: :mri
  gem 'ruby-debug', require: false, platforms: :jruby
end

group :coverage do
  gem 'simplecov', '>= 1.3', require: false
  gem 'simplecov-lcov', require: false
end
