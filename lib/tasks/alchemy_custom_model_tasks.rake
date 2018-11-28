require 'thor'

class Alchemy::Custom::Model::InstallTask < Thor
  include Thor::Actions

  no_tasks do
    def inject_assets
      sentinel = /\*\//
      inject_into_file "./vendor/assets/stylesheets/alchemy/admin/all.css", "\n*= require alchemy-custom-model/manifest.css\n",
                       { before: sentinel, verbose: true }
      append_to_file "./vendor/assets/javascripts/alchemy/admin/all.js", "\n//= require alchemy-custom-model/manifest.js\n",
                       {verbose: true }
    end


  end
end

namespace :alchemy_custom_model do

  desc "installazione gemma"
  task :install do
    # Task goes here
    install_helper = Alchemy::Custom::Model::InstallTask.new

    system("yarn add alchemy-custom-model") || exit!(1)

    install_helper.inject_assets
  end

end
