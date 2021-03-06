# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require './lib/eternity/version'

Gem::Specification.new do |gem|
  gem.name          = "eternity"
  gem.version       = Eternity::VERSION
  gem.authors       = ["Luke Chadwick"]
  gem.email         = ["me@vertis.io"]
  gem.description   = %q{Time range parsing}
  gem.summary       = %q{Time range parsing}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  
  gem.add_dependency("json")
  
  gem.add_development_dependency("rspec")
  gem.add_development_dependency("rubocop")
end
