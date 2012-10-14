require 'spec_helper'

describe NewClothes::Model do
  describe "when included" do
    context "by default" do
      it "finds the corresponding persistent model in the Persistence namespace" do
        define_persistent_model_in_namespace :foo, :Persistence
        define_domain_model_in_namespace :foo, :Domain

        Domain::Foo.persistent_model.should == Persistence::Foo

        remove_namespaces :Persistence, :Domain
      end

      context "with attributes" do
        let(:persistent_model) { define_persistent_model(:foo, :a => :string, :a_count => :integer) }
        let(:domain_model) { define_domain_model persistent_model }

        before { @domain_instance = domain_model.new persistent_model.new }

        it "exposes a hash of the persistent model's content attributes" do
          @domain_instance.attributes.keys.should =~ ["id", "a"]
        end

        it "exposes accessor methods for the persistent model's content attributes" do
          @domain_instance.should respond_to(:id)
          @domain_instance.should respond_to(:a)
          @domain_instance.should_not respond_to(:a_count)
       end
      end
    end

    context "when the persistent namespace is configured" do
      it "finds the corresponding persistent model in the configured namespace" do
        NewClothes.persistent_namespace = "Configured"
        define_persistent_model_in_namespace :foo, :Configured
        define_domain_model_in_namespace :foo, :Domain

        Domain::Foo.persistent_model.should == Configured::Foo

        remove_namespaces :Configured, :Domain
      end
    end

    context "when the persistent model can't be found" do
      specify do
        expect { define_domain_model.persistent_model }.to raise_exception
      end
    end
  end

  describe "specifying the persitent class" do
    it "does not attempt to look up the persistent model in the configured namespace" do
      persistent_model = define_persistent_model :foo
      domain_model = Class.new do
        include NewClothes::Model

        set_persistent_model persistent_model
      end

      domain_model.persistent_model.should == persistent_model
    end
  end
end
