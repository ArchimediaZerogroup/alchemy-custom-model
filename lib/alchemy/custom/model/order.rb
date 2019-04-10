module Alchemy::Custom::Model
  module Order
    extend ActiveSupport::Concern

    included do

      before_action :check_parent


      def new
        if @parent.nil?
          if self.parent_klass.respond_to? :only_current_language
            @elements = self.parent_klass.only_current_language
          else
            @elements = self.parent_klass.all
          end
        else

        end
      end


      def update
        updated_nodes = params[:ordered_data]
        self.parent_klass.transaction do
          process_nodes updated_nodes, self.parent_klass
        end
        redirect_to polymorphic_path([:admin, self.parent_klass])
      end


      private

      def check_parent
        if self.parent_klass.nil?
          raise Errors::ParentNil
        end
      end


      def process_nodes nodes, klass, parent = nil
        nodes.each_with_index do |node, index|
          cp = klass.find node[:id]
          if !parent.nil?
            cp.update_attributes(parent_id: parent, position: index)
          else
            if cp.respond_to? :parent_id
              cp.update_attributes(position: index, parent_id: nil)
            else
              cp.update_attributes(position: index)
            end
          end
          if !node[:children].nil? and !node[:children].empty?
            process_nodes node[:children], klass, cp.id
          end
        end
      end


    end
  end
end