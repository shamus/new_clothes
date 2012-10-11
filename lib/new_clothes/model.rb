require 'new_clothes/model/coupling'

module NewClothes
  module Model
    extend ActiveSupport::Concern

    included do
      extend Coupling
    end
  end
end
