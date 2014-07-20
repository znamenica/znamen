# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'znamen/version'

Gem::Specification.new do |spec|
   spec.name          = "znamen"
   spec.version       = Znamen::VERSION
   spec.authors       = ["Malo Skrylevo"]
   spec.email         = ["majioa@yandex.ru"]
   spec.description   = %q{Рукописи и чисменописи знаменного и демественного роспевов.}
   spec.summary       = %q{Рукописи и чисменописи знаменного и демественного роспевов.}
   spec.homepage      = ""
   spec.license       = "MIT"

   spec.files         = `git ls-files`.split($/)
   spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
   spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
   spec.require_paths = ["lib"]

   spec.add_runtime_dependency "knigodej"

   spec.add_development_dependency "bundler", "~> 1.3"
   spec.add_development_dependency "rake"
   spec.add_development_dependency "pry"
end
