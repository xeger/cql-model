# -*-ruby-*-
require 'rubygems'
require 'bundler/setup'

require 'rake'
require 'rdoc/task'
require 'rubygems/package_task'

require 'rake/clean'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'

require 'jeweler'

desc "Run unit tests"
task :default => :spec

desc "Run unit tests"
RSpec::Core::RakeTask.new do |t|
  t.pattern = Dir['spec/**/*_spec.rb']
end

desc "Run functional tests"
Cucumber::Rake::Task.new do |t|
  t.cucumber_opts = %w{--color --format pretty}
end

desc 'Generate documentation for the cql_model gem.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title    = 'CQLModel'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.md')
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.rdoc_files.exclude('features/**/*')
  rdoc.rdoc_files.exclude('spec/**/*')
end

Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification; see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name                  = "cql_model"
  gem.required_ruby_version = ">= 1.9.0"
  gem.homepage              = "https://github.com/xeger/cql_model"
  gem.license               = "MIT"
  gem.summary               = %Q{Cassandra CQL model.}
  gem.description           = %Q{A lightweight, performant OOP wrapper for Cassandra tables; inspired by DataMapper.}
  gem.email                 = "gemspec@tracker.xeger.net"
  gem.authors               = ['Tony Spataro']
  gem.files.exclude 'features/**/*'
  gem.files.exclude 'spec/**/*'
end

Jeweler::RubygemsDotOrgTasks.new

CLEAN.include('pkg')
