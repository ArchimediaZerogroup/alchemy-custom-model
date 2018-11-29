module Admin
  module Posts
    class CommentsController < Alchemy::Custom::Model::Admin::BaseController

      before_action :load_parent_obj
      skip_before_action :authorize_resource

      def new
        authorize! :create, Comment
        @post.comments.create
        render layout: false
      end

      def update
        authorize! :update, Comment
        super
      end

      private

      def load_parent_obj
        @post = Post.find params[:post_id]
      end

      def base_class
        Comment
      end

      def url_namespace(obj = base_class)
        [:admin, :post, obj]
      end


    end
  end
end