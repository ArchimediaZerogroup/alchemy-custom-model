module Alchemy
  module Custom
    module Model
      class ApplicationController < ActionController::Base
        protect_from_forgery with: :exception
      end
    end
  end
end
