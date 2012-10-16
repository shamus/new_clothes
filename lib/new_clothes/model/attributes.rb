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
          @exposed_attributes ||= expose_default_attributes
        end

        private

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
