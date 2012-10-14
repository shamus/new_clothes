module ModelHelpers
  def define_persistent_model name, attributes = {}
    ActiveRecord::Base.connection.schema_cache.clear!
    ActiveRecord::Base.connection.create_table name, :force => true do |t|
      attributes.each { |name, type| t.column name, type }
    end

    Class.new(ActiveRecord::Base) do
      self.table_name = name
    end
  end

  def define_domain_model persistent_model = nil
    Class.new do
      include NewClothes::Model
      set_persistent_model persistent_model if persistent_model

      def initialize model
        @model = model
      end

      attr_reader :model
    end
  end

  def define_persistent_model_in_namespace model_name, namespace
    define_constant(namespace, Module.new).tap do |namespace|
      define_constant model_name, define_persistent_model(model_name), namespace
    end
  end

  def define_domain_model_in_namespace model_name, namespace
    define_constant(namespace, Module.new).tap do |namespace|
      define_constant model_name, define_domain_model, namespace
    end
  end

  def remove_namespaces *namespaces
    namespaces.each do |namespace|
      Object.class_eval { remove_const namespace }
    end
  end

  private
  def define_constant name, value, namespace = Object
    constant_name = name.to_s.classify.to_sym
    namespace.const_set constant_name, value
  end
end

RSpec.configure do |c|
  c.include ModelHelpers
end
