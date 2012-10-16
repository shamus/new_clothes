module NewClothes
  module Model
    module Attributes
      extend ActiveSupport::Concern

      included do
        def attributes
          HashWithIndifferentAccess.new.tap do |attributes|
            self.class.exposed_attributes.each do |attribute|
              attributes[attribute] = send(attribute)
            end
          end
        end
      end

      module ClassMethods
        def exposed_attributes
          configured_attributes.dup
        end

        def define_attribute attribute, &b
          attribute = attribute.to_s
          configured_attributes << attribute
          define_method attribute, b
        end

        def expose_attribute attribute, &block
          attribute = attribute.to_s
          raise UnknownAttributeError unless persistent_model.column_names.include? attribute

          configured_attributes << attribute

          if block_given?
            define_method attribute do
              block.call model.send(attribute)
            end
          else
            delegate attribute, :to => :model
          end
        end

        def hide_attribute attribute
          attribute = attribute.to_s
          raise UnknownAttributeError unless exposed_attributes.include?(attribute)

          configured_attributes.reject! { |a| a == attribute }
          remove_method attribute if method_defined? attribute
        end

        private

        def configured_attributes
          @configured_attributes ||= expose_default_attributes
        end

        def expose_default_attributes
          [].tap do |configured_attributes|
            default_attributes.each do |a|
              configured_attributes << a
              delegate a, :to => :model
            end
          end
        end

        def default_attributes
          attributes = persistent_model.content_columns.map &:name
          attributes << persistent_model.primary_key
        end
      end
    end
  end
end
