$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "alchemy-custom-model/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "alchemy-custom-model"
  s.version     = Alchemy::Custom::Model::VERSION
  s.authors     = ["Alessandro Baccanelli"]
  s.email       = ["alessandro.baccanelli@archimedianet.it"]
  s.homepage    = ""
  s.summary     = "A gem for semplify model implementation with Alchemy CMS"
  s.description = "A gem for semplify model implementation with Alchemy CMS"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency 'alchemy_cms', '~> 4.0'
  s.add_dependency "jquery-ui-rails", "~> 6.0"
  # s.add_dependency 'friendly_id', '~> 5.2.0'
  # s.add_dependency 'friendly_id-globalize', '~> 1.0.0.alpha3'
  #add globalize to dependency



end
