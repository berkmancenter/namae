# encoding: utf-8

require 'bundler'
begin
  Bundler.setup(:default, :development, :debug, :test)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

desc 'Generate the name parser'
task :racc => ['lib/namae/parser.rb']

file 'lib/namae/parser.rb' => ['lib/namae/parser.y'] do
  sh 'bundle exec racc -o lib/namae/parser.rb lib/namae/parser.y'
end

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:features)

task :default => [:spec, :features]

begin
  require 'coveralls/rake/task'
  Coveralls::RakeTask.new
  task :test_with_coveralls => [:spec, :features, 'coveralls:push']
rescue LoadError
  # ignore
end
