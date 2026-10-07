begin
  require 'simplecov'
  SimpleCov.start
rescue LoadError
  # ignore
end

begin
  require 'debug' 
rescue LoadError
  # ignore
end unless RUBY_PLATFORM == 'java'

$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../lib')
require 'namae'
require 'rspec/expectations'
