require 'active_support/core_ext'
require 'new_clothes/model'
require "new_clothes/version"

module NewClothes
  class << self
    def persistent_class_name_for domain_class_name
      domain_class_name.gsub domain_namespace, persistent_namespace
    end

    def domain_namespace
      @domain_namespace ||= "Domain"
    end

    def persistent_namespace
      @persistent_namespace ||= "Persistence"
    end

    attr_writer :domain_namespace, :persistent_namespace
  end
end
