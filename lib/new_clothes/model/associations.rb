module NewClothes
  module Model
    module Associations
       def expose_association name, options = {}, &b
        reflection = persistent_model.reflect_on_association name
        raise UnknownAssociationError unless reflection

        b = default_transformation_proc(reflection, options[:class]) unless block_given?

        implementation =
          if reflection.collection?
            -> { model.send(name).map { |member| b.call member } }
          else
            -> { b.call model.send(name) }
          end

        define_accessor name, &implementation
      end

      private

      def default_transformation_proc reflection, domain_class = nil
        domain_class = associated_domain_class_for(reflection.klass) unless domain_class
        raise AssociationError unless domain_class.persistent_model.name == reflection.klass.name

        Proc.new { |model| domain_class.new(model) }
      end

      def associated_domain_class_for persistent_class
        associated_class_name = persistent_class.name.demodulize
        name.gsub(/::?\S*$/, "::#{associated_class_name}").constantize
      end
    end
  end
end
