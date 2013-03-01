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
end
