Rails.application.routes.draw do
  mount Alchemy::Custom::Model::Engine => "/alchemy-custom-model"
end
