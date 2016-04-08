# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'quest_back/version'

Gem::Specification.new do |spec|
  spec.name          = "quest_back"
  spec.version       = QuestBack::VERSION
  spec.authors       = ["Thorbjørn Hermansen"]
  spec.email         = ["thhermansen@gmail.com"]
  spec.summary       = %q{Ruby client for QuestBack's SOAP API.}
  #spec.description   = %q{}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", ">= 3.2.14", "< 5"
  spec.add_dependency "savon", "~> 2.11.1"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rspec", "~> 3.4.0"
  spec.add_development_dependency "rake"
end
