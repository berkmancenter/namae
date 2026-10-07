require 'bundler/gem_tasks'

desc 'Generate the name parser'
task :racc => ['lib/namae/parser.rb']

file 'lib/namae/parser.rb' => ['lib/namae/parser.y'] do
  sh 'racc -o lib/namae/parser.rb lib/namae/parser.y'
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:features)

task :default => [:spec, :features]
