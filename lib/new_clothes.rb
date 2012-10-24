require 'active_support/core_ext'
require 'new_clothes/model'
require "new_clothes/version"

module NewClothes
  AssociationError = Class.new StandardError
  UnknownAssociationError = Class.new AssociationError
  UnknownAttributeError = Class.new StandardError

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

    def persistent_namespace= persistent_namespace
      @persistent_namespace = persistent_namespace.to_s
    end

    attr_writer :domain_namespace
  end
end
