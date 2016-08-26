source 'https://rubygems.org'

group :test do
  gem 'rspec', '~>3.0'
  gem 'rake', '~>10.1'
  gem 'cucumber', '~>1.3'
end


group :development do
  gem 'racc', '1.4.9', :platform => :ruby
end

group :coverage do
  gem 'simplecov', '~>0.8', :require => false, :platforms => :ruby
  gem 'rubinius-coverage', '~>2.0', :platform => :rbx
  gem 'coveralls', '~>0.7', :require => false
end

group :optional do
  gem 'ZenTest', '~>4.9'
  gem 'jeweler', '~> 2.0'
  gem 'yard', '~>0.8'
end

group :debug do
  gem 'debugger', '~>1.6', :platform => [:mri_19]
  gem 'byebug', '~>3.5', :platform => :mri if RUBY_VERSION > '2.0'
  gem 'rubinius-compiler', '~>2.0', :platform => :rbx
  gem 'rubinius-debugger', '~>2.0', :platform => :rbx
end

group :osx do
  gem 'autotest-fsevent'
end

group :rbx do
  gem 'rubysl', '~>2.0', :platform => :rbx
  gem 'json', '~>1.8', :platform => :rbx
end
