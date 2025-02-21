require "spec_helper"
require_relative "../lib/field.rb"
require "wrong/adapters/rspec"

describe Field do
  describe "#initialize" do
    it "creates a Field object and freezes it" do
      field = Field.new(:n)
      expect(field.field).to be(:n)
      expect(field.frozen?).to be true
    end
  end

  describe "#==" do
    it "compares two fields, example for two Symbols" do
      n  = Field.new(:n)
      n2 = Field.new(:n)
      m  = Field.new(:m)
      expect(n).to eq(n2)
      expect(n).to_not eq(m)
    end

    it "compares two fields, example for Soot objects" do
      #TODO
    end
  end

  describe "#to_s" do
    it "outputs name of field as string, example symbol" do
      n = Field.new(:some_field_name)
      str = n.to_s
      expect(str).to eq("some_field_name")
    end
  end
end

