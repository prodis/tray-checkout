# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'tray/checkout/version'

Gem::Specification.new do |gem|
  gem.name        = "tray-checkout"
  gem.version     = Tray::Checkout::VERSION
  gem.authors     = ["Prodis a.k.a. Fernando Hamasaki"]
  gem.email       = ["prodis@gmail.com"]
  gem.summary     = "Tray Checkout API"
  gem.description = "Tray Checkout API"
  gem.homepage    = "https://github.com/prodis/tray-checkout"
  gem.licenses    = ["MIT"]

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.platform              = Gem::Platform::RUBY
  gem.required_ruby_version = Gem::Requirement.new(">= 1.9.2")

  gem.add_dependency "activesupport", "~> 3.1"
  gem.add_dependency "log-me", '0.0.9'

  gem.add_development_dependency "pry"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec",   "~> 2.12"
  gem.add_development_dependency "webmock", "~> 1.9"
  gem.add_development_dependency "vcr", "~> 2.6.0"
end
