require 'spec_helper'

require 'persistence/foo'
require 'configured_persistence/bar'
require 'domain/foo'
require 'domain/bar'
require 'domain/misconfigured'

describe NewClothes::Model do
  describe "including NewClothes::Model" do
    context "by default" do
      it "sets the persistent_class attribute on the domain class" do
        Domain::Foo.persistent_class.should == Persistence::Foo
      end

      it "sets the domain_class attribute on the persistent class" do
        Persistence::Foo.domain_class.should == Domain::Foo
      end
    end

    context "when the persistent namespace is configured" do
      before do
        NewClothes.persistent_namespace = "ConfiguredPersistence"
      end

      it "sets the persistent_class attribute on the domain class" do
        Domain::Bar.persistent_class.should == ConfiguredPersistence::Bar
      end
    end

    context "when the persistent class can't be found" do
      specify do
        expect { Domain::Misconfigured.persistent_class }.to raise_exception
      end
    end
  end

  describe "specifying the persitent class" do
    let(:specified_class) do
      Class.new do
        include NewClothes::Model

        set_persistent_class Persistence::Foo
      end
    end

    specify { specified_class.persistent_class.should == Persistence::Foo }
  end
end
