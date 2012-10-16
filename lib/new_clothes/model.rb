require 'new_clothes/model/coupling'
require 'new_clothes/model/associations'
require 'new_clothes/model/attributes'

module NewClothes
  module Model
    extend ActiveSupport::Concern

    included do
      extend Coupling
      extend Associations
      include Attributes

      def method_missing name, *args, &block
        return send name, *args, &block if attributes.has_key? name
        super
      end

      def respond_to? name
        return true if attributes.has_key? name
        super
      end
    end
  end
end
