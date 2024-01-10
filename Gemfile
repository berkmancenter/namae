source 'https://rubygems.org'
gemspec

group :test do
  gem 'rspec'
  gem 'rake'
  gem 'cucumber'
end

group :coverage do
  gem 'simplecov', :require => false, :platforms => :ruby
  gem 'coveralls', :require => false if ENV['CI']
end

group :debug do
  gem 'debug', :platform => [:mri]
end
