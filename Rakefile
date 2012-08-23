#!/usr/bin/env rake
require "bundler/gem_tasks"
require 'rspec/core/rake_task'
require 'cucumber/rake/task'
require 'ci/reporter/rake/rspec'

RSpec::Core::RakeTask.new('spec') do |t|
  t.rspec_opts = '--color --fail-fast'
end


Cucumber::Rake::Task.new('cucumber')

namespace :cucumber do
  Cucumber::Rake::Task.new('aws') do |t|
    t.cucumber_opts = '-p aws'
  end

  Cucumber::Rake::Task.new('openstack') do |t|
    t.cucumber_opts = '-p openstack'
  end

  Cucumber::Rake::Task.new('wip') do |t|
    t.cucumber_opts = '-p wip'
  end
end

desc 'Run the basic test suite'
task :test => ['spec', 'cucumber']

namespace :test do
  desc 'Run all the tests, including the slow (AWS-based) integration tests'
  task :all => ['spec', 'cucumber', 'cucumber:aws']
end


task :default => :test
