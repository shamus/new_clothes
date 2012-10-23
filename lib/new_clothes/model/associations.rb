module NewClothes
  module Model
    module Associations
      def expose_association name, &b
        reflection = persistent_model.reflect_on_association name
        raise UnknownAssociationError unless reflection

        b = default_transformation_proc reflection.klass unless block_given?

        implementation =
          if reflection.collection?
            -> { model.send(name).map { |member| b.call member } }
          else
            -> { b.call model.send(name) }
          end

        define_accessor name, &implementation
      end

      private

      def default_transformation_proc persistent_class
        association_class = NewClothes.domain_class_name_for(persistent_class.name).constantize
        Proc.new { |model| association_class.new(model) }
      end
    end
  end
end
