begin
  require 'simplecov'
  require 'coveralls' if ENV['CI']
rescue LoadError
  # ignore
end unless RUBY_VERSION < '1.9'

begin
  require 'debug' 
rescue LoadError
  # ignore
end unless RUBY_PLATFORM == 'java'

$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../lib')
require 'namae'
require 'rspec/expectations'
