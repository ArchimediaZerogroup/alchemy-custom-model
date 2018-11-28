class Admin::PostsController < Alchemy::Custom::Model::Admin::BaseController

  private

  def base_class
    Post
  end

end
