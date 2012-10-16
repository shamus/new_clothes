module NewClothesHelpers
  def self.register_constant_for_removal constant
    constants_for_removal << constant
  end

  def self.remove_defined_constants
    constants_for_removal.delete_if do |constant|
      Object.class_eval { remove_const constant.name }
    end
  end

  def self.constants_for_removal
    @constants_for_removal ||= []
  end

  class ModelBuilder
    def initialize namespace
      @namespace = namespace
    end

    def define_persistent_model name, attributes = {}, &block
      name = name.to_s.underscore.to_sym

      ActiveRecord::Base.connection.schema_cache.clear!
      ActiveRecord::Base.connection.create_table name, :force => true do |t|
        attributes.each { |name, type| t.column name, type }
      end

      persistent_model = Class.new(ActiveRecord::Base) do
        self.table_name = name
      end

      persistent_model.instance_eval &block if block_given?
      define_constant name, persistent_model
    end

    def define_domain_model name, persistent_model = nil
      domain_model = Class.new do
        include NewClothes::Model
        set_persistent_model persistent_model if persistent_model

        def initialize model
          @model = model
        end

        attr_reader :model
      end

      define_constant name, domain_model
    end

    private
    attr_reader :namespace

    def define_constant name, value
      name = name.to_s.classify.to_sym
      namespace.const_set name, value
    end
  end

  def in_namespace name, &block
    constant = define_constant name
    ModelBuilder.new(constant).instance_eval &block
  end

  private
  def define_constant name
    name = name.to_s.classify.to_sym
    return Object.const_get(name) if Object.const_defined? name

    Object.const_set(name, Module.new).tap do |constant|
      NewClothesHelpers.register_constant_for_removal constant
    end
  end
end

RSpec.configure do |c|
  c.include NewClothesHelpers
  c.after(:each) do
    NewClothesHelpers.remove_defined_constants
  end
end
