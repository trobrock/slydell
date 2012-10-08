# -*- encoding: utf-8 -*-
require File.expand_path('../lib/slydell/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Trae Robrock"]
  gem.email         = ["trobrock@gmail.com"]
  gem.description   = %q{Track the time utilization of methods, including time spent sleeping}
  gem.summary       = %q{Named after Bob Slydell (the Office Space "efficiency expert".
    This gem will help you track the time utilization of certain methods}
  gem.homepage      = "https://github.com/trobrock/slydell"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "slydell"
  gem.require_paths = ["lib"]
  gem.version       = Slydell::VERSION
end
