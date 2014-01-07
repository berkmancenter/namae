source 'https://rubygems.org'

group :test do
  gem 'rspec'
  gem 'rake'
  gem 'cucumber'
end

group :development do
  gem 'racc', '~> 1.4.8', :platform => [:ruby]
  gem 'simplecov', :require => false
  gem 'ZenTest'
  gem 'jeweler', '~> 1.8.3'
  gem 'yard'
end

group :debug do
  gem 'debugger', '~> 1.6', :platform => [:mri_20, :mri_21, :mri_19]
  gem 'rubinius-compiler', '~>2.0', :platform => :rbx
  gem 'rubinius-debugger', '~>2.0', :platform => :rbx
end

group :osx do
  gem 'autotest-fsevent'
end
