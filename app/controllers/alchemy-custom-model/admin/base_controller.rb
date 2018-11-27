module Alchemy::Custom::Model
  module Admin
    class BaseController < Alchemy::Admin::BaseController

      before_action :authorize_resource
      before_action :clean_slug, only: [:create, :update]
      before_action :set_language, unless: -> {params[:language_id].nil?}
      before_action :load_object, except: :index

      helper_method :base_class
      helper_method :table_columns


      def index
        @query = base_class.ransack(params[:q])
        @objects = @query.result(distinct: true)
        @objects = @objects.accessible_by(current_ability).only_current_language
        @objects = @objects.page(params[:page]).
          per(params[:per_page] ||
                (base_class::DEFAULT_PER_PAGE if base_class.const_defined? :DEFAULT_PER_PAGE) ||
                25)
        instance_variable_set "@#{base_class.name.demodulize.underscore.downcase.pluralize}", @objects
      end

      def new

      end

      def edit

      end

      def update
        if @obj.update_attributes(clean_params)
          after_successfull_update
        else
          atfer_unsuccessfull_update
        end
      end

      def destroy
        if @obj.destroy
          after_successful_destroy
        else
          after_unsuccessful_destroy
        end
      end

      def create
        if @obj.update_attributes(clean_params)
          after_successfull_create
        else
          atfer_unsuccessfull_create
        end

      end


      class << self

        mattr_accessor :parent_model_name, :parent_klass, :parent_find_method

        def belongs_to(model_name, options = {})
          prepend_before_action :load_parent
          const_model_klass = options[:model_klass].to_s.constantize unless options[:model_klass].nil?
          self.parent_model_name = model_name.to_s
          self.parent_klass = const_model_klass || self.parent_model_name.to_s.classify.constantize
          self.parent_find_method = options[:find_by].to_s || "id"
        end
      end


      private

      def table_columns
        base_class.columns.collect(&:name).collect {|c| c.to_sym}.reject do |c|
          [
            :created_at,
            :updated_at,
            :id,
            :language_id,
            :meta_keywords,
            :meta_description,
            :meta_title,
            :robot_follow,
            :robot_index
          ].include? c
        end
      end

      def base_class
        raise 'to_override'
      end

      def load_object
        if params[:id]
          if base_class.respond_to? :friendly
            @obj = base_class.friendly.find(params[:id])
          else
            @obj = base_class.find(params[:id])
          end
        else
          @obj = base_class.new
        end
        instance_variable_set("@#{base_class.name.demodulize.underscore.downcase.singularize}", @obj)
      end

      def resource_instance_variable
        @obj
      end


      def authorize_resource
        authorize!(action_name.to_sym, @obj || base_class)
      end

      def permitted_attributes
        base_class.attribute_names.collect {|c| c.to_sym}
      end

      def clean_params
        dati = params.required(base_class.name.underscore.gsub('/', '_').to_sym).permit(permitted_attributes)
        ::Rails.logger.info {"Permitted Attributes: #{permitted_attributes.inspect}"}
        ::Rails.logger.info {"Parametri puliti: #{dati.inspect}"}
        dati
      end

      def clean_slug
        slug = params[base_class.name.underscore.gsub('/', '_').to_sym][:slug]
        if slug.blank?
          params[base_class.name.underscore.gsub('/', '_').to_sym].delete(:slug)
        end
      end

      def after_successful_destroy
        redirect_to polymorphic_path([:admin, @obj.class]), notice: t(:record_succesfully_destroy, model: @obj.class.model_name.human)
      end

      def after_unsuccessful_destroy
        redirect_to polymorphic_path([:admin, @obj.class]), error: t(:record_unsuccesfully_destroy, model: @obj.class.model_name.human)
      end

      def after_successfull_update
        redirect_to polymorphic_path([:admin, @obj.class]), notice: t(:record_succesfully_update, model: @obj.class.model_name.human)
      end

      def atfer_unsuccessfull_update
        render :edit
      end

      def after_successfull_create
        redirect_to polymorphic_path([:admin, @obj.class]), notice: t(:record_succesfully_create, model: @obj.class.model_name.human)
      end

      def atfer_unsuccessfull_create
        render :new
      end


      def set_language
        set_alchemy_language(params[:language_id])
      end


      def load_parent
        unless self.class.parent_model_name.blank?
          @parent = self.class.parent_klass.
            find_by("#{self.class.parent_find_method.to_s}": params["#{parent_model_name_demodulized}_id"])

          instance_variable_set("@#{parent_model_name_demodulized}", @parent)
        end
      end

      def parent_model_name_demodulized
        self.class.parent_model_name.
          classify.demodulize.underscore
      end


    end
  end
end
