# -*- encoding: utf-8 -*-
require File.expand_path('../lib/permalink_fu/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Gonçalo Silva"]
  #gem.email         = ["nobody@example.com"]
  gem.description   = "see https://github.com/goncalossilva/permalink_fu"
  gem.summary       = "see https://github.com/goncalossilva/permalink_fu"
  gem.homepage      = "https://github.com/goncalossilva/permalink_fu"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "permalink_fu"
  gem.require_paths = ["lib"]
  gem.version       = PermalinkFu::VERSION

  gem.add_dependency 'activerecord', '>= 3.2' # FIXME: support other versions too?

  gem.add_development_dependency 'mocha'
  gem.add_development_dependency 'activesupport', '>= 3.2' # FIXME: required at runtime ????
  gem.add_development_dependency 'sqlite3'
  gem.add_development_dependency 'globalize'
  gem.add_development_dependency 'bundler',       '~> 1.3'
  gem.add_development_dependency 'appraisal',     '~> 1.0.0'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'wwtd',          '~> 0.5.1'
end
