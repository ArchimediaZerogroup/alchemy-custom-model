Alchemy::Custom::Model::Engine.routes.draw do

  namespace :admin do
    match '/elfinder_ui' => 'files#ui', via: [:get]
    match '/elfinder' => 'files#elfinder', via: [:get, :post]
  end

end
