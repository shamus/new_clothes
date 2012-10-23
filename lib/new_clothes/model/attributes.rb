module NewClothes
  module Model
    module Attributes
      def self.extended base
        base.define_accessor :attributes do
          HashWithIndifferentAccess.new.tap do |attributes|
            self.class.exposed_attributes.each do |attribute|
              attributes[attribute] = send(attribute)
            end
          end
        end
      end

      def define_attribute attribute, &b
        attribute = attribute.to_s
        configured_attributes << attribute
        define_accessor attribute, &b
      end

      def expose_attribute attribute, &block
        attribute = attribute.to_s
        raise UnknownAttributeError unless persistent_model.column_names.include? attribute

        configured_attributes << attribute

        implementation =
          if block_given?
            -> { block.call model.send(attribute) }
          else
            -> { model.send(attribute) }
          end

        define_accessor attribute, &implementation
      end

      def hide_attribute attribute
        attribute = attribute.to_s
        raise UnknownAttributeError unless exposed_attributes.include?(attribute)

        configured_attributes.reject! { |a| a == attribute }
        remove_accessor attribute
      end

      def exposed_attributes
        configured_attributes.dup
      end

      private

      def configured_attributes
        @configured_attributes ||= expose_default_attributes
      end

      def expose_default_attributes
        [].tap do |configured_attributes|
          default_attributes.each do |a|
            configured_attributes << a
            define_accessor(a) { model.send(a) }
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
