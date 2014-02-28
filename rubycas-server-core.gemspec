# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rubycas-server-core/version'

Gem::Specification.new do |gem|
  gem.name          = "rubycas-server-core"
  gem.version       = RubyCAS::Server::Core::Version::STRING
  gem.authors       = ["Robert Mitwicki", 'Tyler Pickett']
  gem.email         = ["robert.mitwicki@opensoftware.pl", 'tyler@therapylog.com']
  gem.description   = %q{The core logic for handling CAS requests independent of any web presentation technology.}
  gem.summary       = %q{The core logic for handling CAS requests.}
  gem.homepage      = "http://rubycas.github.com"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "r18n-core"
  gem.add_dependency "activesupport", ">= 3.0"

  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "bundler"
end
