Rails.application.routes.draw do


  namespace :admin do
    resources :posts do
      resources :comments, module: :posts
    end
  end


  mount Alchemy::Custom::Model::Engine => '/alchemy-custom-model'
  mount Alchemy::Engine => '/'

end
