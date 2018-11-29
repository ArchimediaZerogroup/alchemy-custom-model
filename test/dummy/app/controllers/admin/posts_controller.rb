class Admin::PostsController < Alchemy::Custom::Model::Admin::BaseController

  private

  def base_class
    Post
  end

  def permitted_attributes
    super + [:picture, :file, comments_attributes: [:author,
                                                    :description,
                                                    :file_id,
                                                    :file,
                                                    :_destroy,
                                                    :id,
                                                    :position,
                                                    comment_pictures_attributes: [:id, :position]]
    ]
  end

end
