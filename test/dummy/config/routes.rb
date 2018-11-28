Rails.application.routes.draw do


  namespace :admin do
    resources :posts
  end

  mount Alchemy::Engine => '/'

  mount Alchemy::Custom::Model::Engine => "/alchemy-custom-model"

end
