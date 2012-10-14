module NewClothes
  module Model
    module Coupling
      def persistent_model
        @persistent_model || set_persistent_model(default_persistent_model)
      end

      def set_persistent_model persistent_model
        @persistent_model = persistent_model
      end

      private

      def default_persistent_model
        NewClothes.persistent_class_name_for(self.name).constantize
      end
    end
  end
end
