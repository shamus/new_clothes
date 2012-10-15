require 'spec_helper'

describe NewClothes::Model do
  describe "when included" do
    context "by default" do
      it "finds the corresponding persistent model in the Persistence namespace" do
        in_namespace(:Persistence) { define_persistent_model :foo }
        in_namespace(:Domain) { define_domain_model :foo }

        Domain::Foo.persistent_model.should == Persistence::Foo
      end

      context "with attributes" do
        before do
          in_namespace(:Persistence) { define_persistent_model :foo, :a => :string, :a_count => :integer }
          in_namespace(:Domain) { define_domain_model :foo }

          @domain_instance = Domain::Foo.new(Persistence::Foo.new)
        end

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
        in_namespace(:Configured) { define_persistent_model :foo }
        in_namespace(:Domain) { define_domain_model :foo }

        Domain::Foo.persistent_model.should == Configured::Foo
      end
    end

    context "when the persistent model can't be found" do
      specify do
        expect do
          in_namespace(:Domain) { define_domain_model.persistent_model }
        end.to raise_exception
      end
    end
  end

  describe "specifying the persitent class" do
    it "does not attempt to look up the persistent model in the configured namespace" do
      in_namespace(:Specified) { define_persistent_model :foo }
      domain_model = Class.new do
        include NewClothes::Model

        set_persistent_model Specified::Foo
      end

      domain_model.persistent_model.should == Specified::Foo
    end
  end
end
