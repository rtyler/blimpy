#!/usr/bin/env rake
require "bundler/gem_tasks"
require 'rspec/core/rake_task'
require 'cucumber/rake/task'

RSpec::Core::RakeTask.new('spec') do |t|
  t.rspec_opts = '--color --fail-fast'
end

Cucumber::Rake::Task.new('cucumber') do |t|
  t.cucumber_opts = '--color --format progress --tags ~@wip'
end

task :test => [:spec, :cucumber]

