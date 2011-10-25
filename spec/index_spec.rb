require 'spec_helper'

describe RspecApiDocumentation::Index do
  let(:foo_example_group) { RSpec::Core::ExampleGroup.describe("Foo", :resource_name => "Foo", :document => true) }
  let(:bar_example_group) { RSpec::Core::ExampleGroup.describe("Bar", :resource_name => "Bar", :document => true) }
  let(:foo_examples) { Array.new(2) { |i| foo_example_group.example("Foo #{i}") {} } }
  let(:bar_examples) { Array.new(2) { |i| bar_example_group.example("Bar #{i}") {} } }
  let(:examples) { foo_examples + bar_examples }
  let(:index) { RspecApiDocumentation::Index.new }

  subject { index }

  it { should be_a(Mustache) }

  its(:example_groups) { should be_empty }

  describe "#add_example" do
    let(:wrapped_foo_example_group) { stub }
    let(:wrapped_bar_example_group) { stub }

    before do
      RspecApiDocumentation::ExampleGroup.stub!(:new).with(foo_example_group).and_return(wrapped_foo_example_group)
      RspecApiDocumentation::ExampleGroup.stub!(:new).with(bar_example_group).and_return(wrapped_bar_example_group)
    end

    it "should wrap and add the given example's group to example_groups" do
      index.add_example(foo_examples.first)
      index.example_groups.should eq([wrapped_foo_example_group])
    end

    it "should support multiple example groups" do
      index.add_example(foo_examples.first)
      index.add_example(bar_examples.first)
      index.example_groups.should eq([wrapped_foo_example_group, wrapped_bar_example_group])
    end

    it "should not add the same example group twice" do
      foo_examples.each do |example|
        index.add_example(example)
      end
      index.example_groups.should eq([wrapped_foo_example_group])
    end
  end

  describe "#examples" do
    let(:wrapped_examples) { [stub] * examples.count }

    before do
      RspecApiDocumentation::Example.stub!(:new).and_return(*wrapped_examples)
      examples.each { |example| index.add_example(example) }
    end

    it "should return the added examples, wrapped" do
      index.examples.should eq(wrapped_examples)
    end
  end
end
