#!/usr/bin/env rake
# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'bundler/setup'
require 'appraisal'
require 'rake'
require 'rake/testtask'

desc 'Default: run unit tests with current rails version.'
task default: :test

desc 'Run tests with all supported Rails versions.'
task :all do
  exec('bundle exec appraisal install && bundle exec appraisal rake test')
end

desc 'Test the permalink_fu.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
  t.warning = false
end
