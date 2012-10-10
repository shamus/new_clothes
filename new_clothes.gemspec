# -*- encoding: utf-8 -*-
require File.expand_path('../lib/new_clothes/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Jeremy Morony"]
  gem.email         = ["jeremy@break-up.us"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "new_clothes"
  gem.require_paths = ["lib"]
  gem.version       = NewClothes::VERSION

  gem.add_dependency 'activemodel'
  gem.add_dependency 'activesupport'
  gem.add_dependency 'activerecord'

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "rr"
end
