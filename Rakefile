#!/usr/bin/env rake
require "bundler/gem_tasks"
require 'rspec/core/rake_task'
require 'cucumber/rake/task'

RSpec::Core::RakeTask.new('spec') do |t|
  t.rspec_opts = '--color --fail-fast'
end


namespace :cucumber do
  cucumber_opts = '--color --format progress --tags ~@wip'

  Cucumber::Rake::Task.new('basic') do |t|
    t.cucumber_opts = cucumber_opts + ' --tags ~@slow'
  end

  Cucumber::Rake::Task.new('integration') do |t|
    t.cucumber_opts = cucumber_opts + '--tags @slow'
  end
end

task :test => [:spec, :"cucumber:basic"]

