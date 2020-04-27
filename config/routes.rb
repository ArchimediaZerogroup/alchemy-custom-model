Alchemy::Custom::Model::Engine.routes.draw do

  namespace :admin do
    match '/elfinder_ui' => 'files#ui', via: [:get]
    match '/elfinder' => 'files#elfinder', via: [:get, :post]
  end

end


Alchemy::Engine.routes.draw do

  if "Alchemy::Node".safe_constantize
    namespace :admin do
      resources :nodes do
        collection do
          get :custom_models, defaults: {format: 'json'}, constraints: {format: :json}
          get :custom_models_methods, defaults: {format: 'json'}, constraints: {format: :json}
        end
      end
    end
  end
end

