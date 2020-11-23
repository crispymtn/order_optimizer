lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "order_optimizer/version"

Gem::Specification.new do |spec|
  spec.name     = "order_optimizer"
  spec.version  = OrderOptimizer::VERSION

  spec.authors  = ["crispymtn", "Martin Spickermann", "Maurice Vogel"]
  spec.email    = ["op@crispymtn.com", "spickermann@gmail.com"]
  spec.homepage = "https://github.com/crispymtn/order_optimizer"
  spec.license  = "MIT"
  spec.summary  = "Helps to optimize orders if the goods are offered in different pack sizes and in different discount levels."


  spec.metadata["changelog_uri"] = "https://github.com/crispymtn/order_optimizer/blob/master/CHANGELOG.md"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "rake"
end
