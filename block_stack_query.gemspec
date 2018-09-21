
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "block_stack/query/version"

Gem::Specification.new do |spec|
  spec.name          = "block_stack_query"
  spec.version       = BlockStack::Query::VERSION
  spec.authors       = ["Brandon Black"]
  spec.email         = ["d2sm10@hotmail.com"]

  spec.summary       = %q{A query DSL that aims to be technology agnostic.}
  spec.description   = %q{A uniform query language that can be used anywhere, but is designed to function with BlockStack.}
  spec.homepage      = "https://github.com/bblack16/block-stack-query"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'bblib', '~> 2.0'
  spec.add_runtime_dependency 'block_stack_util', '~> 1.0'

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
