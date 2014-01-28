source 'https://rubygems.org'

group :test do
  gem 'rspec', '~>2.14'
  gem 'rake', '~>10.1'
  gem 'cucumber', '~>1.3'
end


group :development do
  gem 'simplecov', '~>0.8', :require => false, :platforms => [:ruby_19, :ruby_20, :ruby_21]
  gem 'rubinius-coverage', '~>2.0', :platform => :rbx
  gem 'coveralls', '~>0.7', :require => false, :platforms => [:ruby_21]
  gem 'racc', '1.4.9', :platform => [:ruby]
end

group :optional do
  gem 'ZenTest', '~>4.9'
  gem 'jeweler', '~> 2.0'
  gem 'yard', '~>0.8'
end

group :debug do
  gem 'debugger', '~>1.6', :platform => [:mri_20, :mri_21, :mri_19]
  gem 'rubinius-compiler', '~>2.0', :platform => :rbx
  gem 'rubinius-debugger', '~>2.0', :platform => :rbx
end

group :osx do
  gem 'autotest-fsevent'
end

platform :rbx do
  gem 'rubysl', '~>2.0'
end
