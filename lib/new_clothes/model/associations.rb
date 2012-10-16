module NewClothes
  module Model
    module Associations
      def expose_association name, &b
        reflection = persistent_model.reflect_on_association name
        b = default_proc reflection.klass unless block_given?

        method_body =
          if reflection.collection?
            -> { model.send(name).map { |member| b.call member } }
          else
            -> { b.call model.send(name) }
          end

        define_method name, method_body
      end

      private

      def default_proc persistent_class
        association_class = NewClothes.domain_class_name_for(persistent_class.name).constantize
        Proc.new { |model| association_class.new(model) }
      end
    end
  end
end
