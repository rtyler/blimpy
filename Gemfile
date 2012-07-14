source 'https://rubygems.org'

# Specify your gem's dependencies in blimpy.gemspec
gemspec

group :development do
  gem 'rake'
  gem 'rspec'
  gem 'cucumber'
  gem 'aruba'
  gem 'tempdir'
  gem 'pry'
  if RUBY_VERSION > '1.9'
    gem 'ruby-debug19', :require => 'ruby-debug'
  else
    gem 'ruby-debug'
  end
end
