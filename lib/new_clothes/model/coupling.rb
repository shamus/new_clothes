module NewClothes
  module Model
    module Coupling
      def persistent_class
        @persistent_class || set_persistent_class(persistent_class_name.constantize)
      end

      def set_persistent_class persistent_class
        domain_class = self
        persistent_class.singleton_class.instance_eval do
          define_method(:domain_class) { domain_class }
        end

        @persistent_class = persistent_class
      end

      private

      def persistent_class_name
        @persistent_class_name ||= NewClothes.persistent_class_name_for self.name
      end
    end
  end
end
