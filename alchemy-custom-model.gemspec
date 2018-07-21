$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "alchemy/custom/model/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "alchemy-custom-model"
  s.version     = Alchemy::Custom::Model::VERSION
  s.authors     = ["Alessandro Baccanelli"]
  s.email       = ["alessandro.baccanelli@archimedianet.it"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Alchemy::Custom::Model."
  s.description = "TODO: Description of Alchemy::Custom::Model."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.2.0"
  s.add_dependency 'alchemy_cms', '~> 4.0'


end
