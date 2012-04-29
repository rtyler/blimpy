# -*- encoding: utf-8 -*-
require File.expand_path('../lib/blimpy/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["R. Tyler Croy"]
  gem.email         = ["tyler@monkeypox.org"]
  gem.description   = %q{Blimpy is a tool for managing a fleet of machines in the CLOUD!}
  gem.summary       = %q{Ruby + CLOUD = Blimpy}
  gem.homepage      = "https://github.com/rtyler/blimpy"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "blimpy"
  gem.require_paths = ["lib"]
  gem.version       = Blimpy::VERSION

  gem.add_dependency 'fog'
  gem.add_dependency 'thor'
  gem.add_dependency 'minitar'
end
