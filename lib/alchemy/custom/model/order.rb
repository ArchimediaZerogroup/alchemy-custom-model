module Alchemy::Custom::Model
  module Order
    extend ActiveSupport::Concern

    included do

      before_action :check_parent
      helper_method :parent_klass


      def new
        @obj = @parent
        if @parent.nil?
          if self.parent_klass.respond_to? :only_current_language
            @elements = self.parent_klass.only_current_language
          else
            @elements = self.parent_klass.all
          end
        else

          if @parent.respond_to? self.class.method_for_show
            @elements = @parent.send(self.class.method_for_show.to_sym)
            @elements = @elements.accessible_by(current_ability)

          else
            @elements = base_class.none
          end

        end
      end


      def update
        if !self.class.method_for_show.blank? and !@parent.nil?
          klass= klass_for_show_elements
        else
          klass= self.parent_klass
        end
        updated_nodes = params[:ordered_data]
        klass.transaction do
          process_nodes updated_nodes, klass
        end
        redirect_to polymorphic_path([:admin, self.parent_klass])
      end

      protected

      def parent_klass
        self.class.parent_klass
      end

      def klass_for_show_elements
        self.class.method_for_show.to_s.singularize.classify.constantize
      end

      private

      def check_parent
        if self.parent_klass.nil?
          raise Errors::ParentNil
        end
      end

      def base_class
        parent_klass
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