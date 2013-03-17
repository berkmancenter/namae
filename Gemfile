source 'https://rubygems.org'

group :test do
  gem 'rspec'
  gem 'rake'
  gem 'cucumber'
end

group :development do
  gem 'racc', '~> 1.4.8', :platform => [:ruby_20, :ruby_19, :ruby_18]
  gem 'simplecov', :require => false
  gem 'ZenTest'
  gem 'jeweler', '~> 1.8.3'
  gem 'yard'
end

group :debug do
  gem 'debugger', '~> 1.1.3', :platform => [:mri_20, :mri_19]
end

group :osx do
  gem 'autotest-fsevent'
end
