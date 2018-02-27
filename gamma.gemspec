
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "gamma/version"

Gem::Specification.new do |spec|
  spec.name          = "gamma"
  spec.version       = Gamma::VERSION
  spec.authors       = ["Shinsuke Nishio"]
  spec.email         = ["nishio@densan-labs.net"]

  spec.summary       = %q{DBSync}
  spec.description   = %q{DBSync}
  spec.homepage      = "https://github.com/nishio-dens/gamma"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "mysql2"
  spec.add_dependency "activesupport"
  spec.add_dependency "thor", "~> 0.20"
  spec.add_dependency "colorize", "~> 0.8.1"

  spec.required_ruby_version = ">= 2.3.0"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "pry"
end
