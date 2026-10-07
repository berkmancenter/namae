begin
  require 'simplecov'
  SimpleCov.start
rescue LoadError
  # ignore
end

require 'namae'

Before do
  Thread.current[:namae] = nil
end
