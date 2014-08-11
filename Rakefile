#!/usr/bin/env rake
require 'bundler/gem_tasks'
require 'bundler/setup'
require 'appraisal'
require 'rake'
require 'rake/testtask'
require 'wwtd/tasks'

desc 'Default: run unit tests.'
task :default => :test

task :local => "wwtd:local" # run all gemfiles with local ruby

desc 'Run tests with all supported Rails versions.'
task :all => ["appraisal:install"] do
  exec('rake appraisal test')
end

desc 'Test the permalink_fu.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end
