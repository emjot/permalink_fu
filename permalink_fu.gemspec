# frozen_string_literal: true

require 'English'

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'permalink_fu/version'

Gem::Specification.new do |gem|
  gem.authors       = ['Gonçalo Silva']
  # gem.email         = ["nobody@example.com"]
  gem.description   = 'see https://github.com/goncalossilva/permalink_fu'
  gem.summary       = 'see https://github.com/goncalossilva/permalink_fu'
  gem.homepage      = 'https://github.com/goncalossilva/permalink_fu'

  gem.files         = `git ls-files`.split($OUTPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.name          = 'permalink_fu'
  gem.require_paths = ['lib']
  gem.version       = PermalinkFu::VERSION

  gem.required_ruby_version = '>= 3.0.0'

  gem.add_dependency 'activerecord', ['>= 7.0', '< 9']
  gem.add_dependency 'globalize', '~> 7.1'
  gem.metadata['rubygems_mfa_required'] = 'true'
end
