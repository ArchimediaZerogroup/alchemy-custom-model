namespace :alchemy_custom_model do

  desc "installazione gemma"
  task :install do
    # Task goes here

    system("yarn add alchemy-custom-model") || exit!(1)


  end

end
