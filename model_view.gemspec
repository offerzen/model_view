Gem::Specification.new do |spec|
  spec.name        = 'model_view'
  spec.version     = '0.0.0'
  spec.date        = '2017-06-13'
  spec.summary     = "Composable serialisation for models"
  spec.description = "Composable serialisation for models"
  spec.authors     = ["Martin Pretorius"]
  spec.email       = ['martin@offerzen.com', 'glasnoster@gmail.com']
  spec.homepage    = 'https://github.com/Offerzen/model_view'
  spec.license     = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "semvergen", "~> 1.9"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake",    "~> 10.0"
  spec.add_development_dependency "rspec",   "~> 3.0"
  spec.add_development_dependency "pry",     "~> 0.10"
end