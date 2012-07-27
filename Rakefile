#!/usr/bin/env rake
require "bundler/gem_tasks"
require 'rspec/core/rake_task'
require 'cucumber/rake/task'
require 'ci/reporter/rake/rspec'

RSpec::Core::RakeTask.new('spec') do |t|
  t.rspec_opts = '--color --fail-fast'
end


namespace :cucumber do
  cucumber_opts = '--color --format progress --tags ~@wip'

  Cucumber::Rake::Task.new('basic') do |t|
    t.cucumber_opts = cucumber_opts + ' --tags ~@slow'
  end

  Cucumber::Rake::Task.new('integration') do |t|
    t.cucumber_opts = cucumber_opts + ' --tags @slow --tags ~@openstack'
  end

  Cucumber::Rake::Task.new('openstack') do |t|
    t.cucumber_opts = cucumber_opts + ' --tags @openstack'
  end
end

desc 'Run the basic test suite'
task :test => [:spec, :"cucumber:basic"]

namespace :test do
  desc 'Run all the tests, including the slow integration tests'
  task :all => [:spec, :'cucumber:basic', :'cucumber:integration']
end


task :default => :test
