# encoding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'permalink_fu/version'

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

  gem.add_dependency 'activerecord', ['>= 5.1', '< 8'] # FIXME: support other versions too?

  gem.add_development_dependency 'mocha'
  gem.add_development_dependency 'activesupport', ['>= 5.1', '< 8'] # FIXME: required at runtime ????
  gem.add_development_dependency 'sqlite3',       '~> 1.5.0'
  gem.add_development_dependency 'globalize'
  gem.add_development_dependency 'bundler',       '~> 2.3'
  gem.add_development_dependency 'appraisal',     '~> 2.0'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'wwtd',          '~> 1.0'
end
