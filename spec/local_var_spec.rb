require "spec_helper"
require_relative "../lib/local_var.rb"
require "wrong/adapters/rspec"

describe LocalVar do
  describe "#initialize" do
    it "creates a Field object and freezes it" do
      var = LocalVar.new(:x)
      expect(var.var).to eq(:x)
      expect(var.frozen?).to be true
    end
  end

  describe "#==" do
    it "compares two LocalVars, example for two Symbols" do
      x  = LocalVar.new(:x)
      x2 = LocalVar.new(:x)
      y  = LocalVar.new(:y)
      expect(x).to eq(x2)
      expect(x).to_not eq(y)
    end

    it "compares two LocarVars, example for Soot objects" do
      #TODO
    end
  end

  describe "#to_s" do
    it "outputs name of LocarVar as string, example symbol" do
      var = Field.new(:some_var_name)
      str = var.to_s
      expect(str).to eq("some_var_name")
    end
  end
end

