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

          @persistent_instance = Persistence::Foo.new :a => "a"
          @domain_instance = Domain::Foo.new(@persistent_instance)
        end

        it "exposes a hash of the persistent model's content attributes" do
          @domain_instance.attributes.keys.should =~ ["id", "a"]
        end

        it "exposes accessor methods for the persistent model's content attributes" do
          @domain_instance.id.should == @persistent_instance.id
          @domain_instance.a.should == @persistent_instance.a
          @domain_instance.should_not respond_to(:a_count)
        end
      end
    end

    context "when the persistent namespace is configured" do
      before { NewClothes.persistent_namespace = "Configured" }
      after { NewClothes.persistent_namespace = "Persistence" }

      it "finds the corresponding persistent model in the configured namespace" do
        in_namespace(:Configured) { define_persistent_model :foo }
        in_namespace(:Domain) { define_domain_model :foo }

        Domain::Foo.persistent_model.should == Configured::Foo
      end
    end

    context "when there is no persistent namespace" do
      before { NewClothes.persistent_namespace = nil }
      after { NewClothes.persistent_namespace = "Persistence" }

      it "finds the corresponding persistent model in the top level namespace" do
        top_level_namespace { define_persistent_model :foo }
        in_namespace(:Domain) { define_domain_model :foo }

        Domain::Foo.persistent_model.should == ::Foo
      end
    end

    context "when the persistent model can't be found" do
      before do
        in_namespace(:Domain) { define_domain_model(:foo) }
      end

      specify do
        expect { Domain::Foo.persistent_model }.to raise_exception(NameError)
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

  describe "exposing an attribute" do
    before do
      in_namespace(:Persistence) { define_persistent_model :foo, :a_count => :integer }
      in_namespace(:Domain) { define_domain_model :foo }
    end

    context "by default" do
      before do
        Domain::Foo.expose_attribute :a_count
        @persistent_instance = Persistence::Foo.new :a_count => 1
        @domain_instance = Domain::Foo.new(@persistent_instance)
      end

      it "includes the attribute in the exposed attributes list" do
        Domain::Foo.exposed_attributes.should include("a_count")
      end

      it "includes the attribute in the domain model's attributes hash" do
        @domain_instance.attributes[:a_count].should == @persistent_instance.a_count
      end

      it "exposes an accessor method for the attribute" do
        @domain_instance.a_count.should == @persistent_instance.a_count
      end
    end

    context "with a block" do
      before do
        @yielded = nil
        Domain::Foo.expose_attribute(:a_count) do |value|
          @yielded = value
          :transformed
        end
        @persistent_instance = Persistence::Foo.new :a_count => 1
        @domain_instance = Domain::Foo.new(@persistent_instance)
      end

      it "defines an attribute accessor using the supplied block" do
        @domain_instance.a_count.should == :transformed
        @yielded.should == @persistent_instance.a_count
      end

      it "includes the attribute in the domain model's attributes hash" do
        @domain_instance.attributes[:a_count].should == :transformed
      end
    end

    context "when the attribute doesn't exist" do
      specify do
        expect { Domain::Foo.expose_attribute :unknown }.to raise_exception(NewClothes::UnknownAttributeError)
      end
    end
  end

  describe "hiding an attribute" do
    before do
      in_namespace(:Persistence) { define_persistent_model :foo, :a => :string, :a_count => :integer }
      in_namespace(:Domain) { define_domain_model :foo }
    end

    context "by default" do
      before do
        @domain_instance = Domain::Foo.new(Persistence::Foo.new)
        @domain_instance.should respond_to(:a)
        @domain_instance.attributes.should have_key(:a)

        Domain::Foo.hide_attribute :a
      end

      it "removes the attribute from the attributes hash" do
        @domain_instance.attributes.should_not have_key(:a)
      end

      it "removes the attribute accessor" do
        @domain_instance.should_not respond_to(:a)
      end
    end

    context "when the attribute isn't exposed" do
      specify do
        Domain::Foo.instance_methods.should_not include(:a_count)
        expect { Domain::Foo.hide_attribute :a_count }.to raise_exception(NewClothes::UnknownAttributeError)
      end
    end
  end

  describe "defing an attribute" do
    before do
      in_namespace(:Persistence) { define_persistent_model :foo }
      in_namespace(:Domain) { define_domain_model :foo }

      Domain::Foo.define_attribute :defined do
        :defined
      end

      @domain_instance = Domain::Foo.new(Persistence::Foo.new)
    end

    it "includes the attribute in the domain model's attributes hash" do
      @domain_instance.attributes[:defined].should == :defined
    end

    it "exposes an accessor method for the attribute" do
      @domain_instance.defined.should == :defined
    end
  end

  describe "exposing an association" do
    before do
      in_namespace :Persistence do
        define_persistent_model :bar, :foo_id => :integer
        define_persistent_model :baz, :foo_id => :integer
        define_persistent_model :foo do
          has_many :bars
          has_one :baz
        end
      end

      in_namespace(:Domain) { define_domain_model :foo }
    end

    context "which is single valued" do
      context "by default" do
        before do
          in_namespace(:Domain) { define_domain_model :baz }
          Domain::Foo.expose_association :baz
        end

        it "transforms the value of the association into the domain class" do
          persistent_instance = Persistence::Foo.new
          persistent_instance.build_baz
          domain_instance = Domain::Foo.new(persistent_instance)
          domain_instance.baz.should be_a(Domain::Baz)
        end
      end

      context "when configuring the association target domain class" do
        it "uses the specified :class option" do
          in_namespace(:Domain) { define_domain_model :qux, Persistence::Baz }
          Domain::Foo.expose_association :baz, :class => Domain::Qux

          persistent_instance = Persistence::Foo.new
          persistent_instance.build_baz
          domain_instance = Domain::Foo.new(persistent_instance)
          domain_instance.baz.should be_a(Domain::Qux)
        end
      end

      context "when no corresponding domain model can be found" do
        specify do
          expect { Domain::Foo.expose_association :baz }.to raise_exception(NameError)
        end
      end

      context "when the corresponding domain model doesn't map to the type of the association" do
        before do
          in_namespace(:Domain) { define_domain_model :baz, Persistence::Bar }
        end

        specify do
          expect { Domain::Foo.expose_association :baz }.to raise_exception(NewClothes::AssociationError)
        end
      end

      context "with a block" do
        before do
          @yielded = false
          Domain::Foo.expose_association(:baz) do |member|
            @yielded = member
            :transformed
          end
        end

        it "yields the value of the association to the block and returns the result" do
          persistent_instance = Persistence::Foo.new
          baz = persistent_instance.build_baz
          Domain::Foo.new(persistent_instance).baz.should == :transformed
          @yielded.should == baz
        end
      end
    end

    context "which is a collection" do
      context "by default" do
        before do
          in_namespace(:Domain) { define_domain_model :bar }
          Domain::Foo.expose_association :bars
        end

        it "transforms each value of the association into the domain class" do
          persistent_instance = Persistence::Foo.new
          domain_instance = Domain::Foo.new(persistent_instance)
          2.times { persistent_instance.bars.build }

          domain_instance.bars.length.should == 2
          domain_instance.bars.first.should be_a(Domain::Bar)
          domain_instance.bars.last.should be_a(Domain::Bar)
        end
      end

      context "when no corresponding domain model can be found" do
        specify do
          expect { Domain::Foo.expose_assocition :bar }.to raise_exception
        end
      end

      context "when the corresponding domain model doesn't map to the type of the association" do
        before do
          in_namespace(:Domain) { define_domain_model :bar, Persistence::Baz }
        end

        specify do
          expect { Domain::Foo.expose_association :bar }.to raise_exception(NewClothes::AssociationError)
        end
      end

      context "with a block" do
        before do
          @yielded = 0
          Domain::Foo.expose_association(:bars) do |member|
            @yielded += 1
            :transformed
          end
        end

        it "yields each value of the association to the block and returns the result" do
          persistent_instance = Persistence::Foo.new
          domain_instance = Domain::Foo.new(persistent_instance)
          2.times { persistent_instance.bars.build }

          domain_instance.bars.should == [:transformed, :transformed]
          @yielded.should == 2
        end
      end

      context "when the association doesn't exist" do
        specify do
          expect { Domain::Foo.expose_association :unknown }.to raise_exception(NewClothes::UnknownAssociationError)
        end
      end
    end
  end
end
