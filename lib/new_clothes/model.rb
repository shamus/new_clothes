require 'new_clothes/model/coupling'
require 'new_clothes/model/attributes'

module NewClothes
  module Model
    extend ActiveSupport::Concern

    included do
      extend Coupling
      include Attributes
    end
  end
end
