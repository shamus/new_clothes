require 'new_clothes/model/coupling'
require 'new_clothes/model/associations'
require 'new_clothes/model/attributes'

module NewClothes
  module Things
    def define_accessor name, &block
      accessors_module.class_eval do
        define_method name, &block
      end
    end

    def remove_accessor name
      accessors_module.class_eval do
        remove_method name if method_defined? name
      end
    end

    private

    def accessors_module
      @accessors_module ||= Module.new
    end
  end

  module Model
    def self.included base
      base.instance_eval do
        extend Things
        extend Coupling
        extend Associations
        extend Attributes
        include accessors_module
      end
    end

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
