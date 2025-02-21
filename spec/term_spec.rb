require "spec_helper"
require_relative "../lib/term.rb"
require "wrong/adapters/rspec"

describe Term do
  describe "#initialize" do
    it "creates a term object using given objects and freezes it" do
      var = LocalVar.new(:x)
      field1 = Field.new(:n)
      field2 = Field.new(:m)

      term0 = Term.new(var)
      expect(term0.var).to be(var)
      expect(term0.accessed_fields).to eq([])
      expect(term0.frozen?).to be true

      term1 = Term.new(var, field1, field2)
      expect(term1.var).to be(var)
      expect(term1.accessed_fields[0]).to be(field1)
      expect(term1.accessed_fields[1]).to be(field2)
      expect(term1.frozen?).to be true

      term2 = Term.new(var, field1, field1)
      expect(term2.var).to be(var)
      expect(term2.accessed_fields[0]).to be(field1)
      expect(term2.accessed_fields[1]).to be(field1)
      expect(term2.frozen?).to be true
    end
  end

  describe "#initialize" do
    it "creates a term object if given a string and freezes it" do
      term1 = Term.from_string("x")
      term2 = Term.from_string("y.n")
      term3 = Term.from_string("z.m.l")

      expect(term1.var).to eq(LocalVar.new(:x))

      expect(term2.var).to eq(LocalVar.new(:y))
      expect(term2.accessed_fields).to eq([Field.new(:n)])

      expect(term3.var).to eq(LocalVar.new(:z))
      expect(term3.accessed_fields).to eq([Field.new(:m), Field.new(:l)])
    end
  end

  describe "#==" do
    it "compares two terms, example for two terms with Symbols only" do
      term1  = Term.from_string("x.n")
      term2  = Term.from_string("x.n")
      expect(term1).to eq(term2)

      term3  = Term.from_string("x.m")
      expect(term1).to_not eq(term3)

      term4  = Term.from_string("x.n.n")
      expect(term1).to_not eq(term4)
    end

    it "compares two terms, example for Soot objects" do
      #TODO
    end
  end

  describe "#to_s" do
    it "returns string representation of term as varname.fieldname1.fieldname2, example symbol" do
      str = Term.from_string("x.n.m").to_s
      expect(str).to eq("x.n.m")
    end
  end

  describe "#prefix_of?" do
    it "returns true if first term is prefix of or equal to second term, example with Symbols" do
      term1  = Term.from_string("x.n")
      term2  = Term.from_string("x.n")
      expect(term1.prefix_of?(term2)).to be true

      term3  = Term.from_string("x.n.m")
      expect(term1.prefix_of?(term3)).to be true

      term4  = Term.from_string("x.m")
      expect(term1.prefix_of?(term4)).to be false

      term5 = Term.from_string("y.n")
      expect(term1.prefix_of?(term5)).to be false

      term6 = Term.from_string("y.n.m")
      expect(term1.prefix_of?(term6)).to be false
    end
  end

  describe "#real_prefix_of?" do
    it "returns true if first term is prefix of, but not equal to second term, example with Symbols" do
      term1  = Term.from_string("x.n")
      term2  = Term.from_string("x.n")
      expect(term1.real_prefix_of?(term2)).to be false

      term3  = Term.from_string("x.n.m")
      expect(term1.real_prefix_of?(term3)).to be true

      term4  = Term.from_string("x.m")
      expect(term1.real_prefix_of?(term4)).to be false
    end
  end

  describe "#replace" do
    it "replaces old_term in self with new_term, doesn't alter itself" do
      term = Term.from_string("x.n.n.n")
      old = Term.from_string("x")
      new = Term.from_string("y.m")
      new_term = term.replace(old, new)
      expect(new_term).to eq(Term.from_string("y.m.n.n.n"))
    end

    it "replaces old_term in self with new_term, doesn't alter itself" do
      term = Term.from_string("x.n.n.n")
      old = Term.from_string("x")
      new = Term.from_string("y")
      new_term = term.replace(old, new)
      expect(new_term).to eq(Term.from_string("y.n.n.n"))
    end

    it "replaces old_term in self with new_term, doesn't alter itself" do
      term = Term.from_string("x.n.n.n")
      old = Term.from_string("x.n")
      new = Term.from_string("y")
      new_term = term.replace(old, new)
      expect(new_term).to eq(Term.from_string("y.n.n"))
    end

    it "replaces old_term in self with new_term, doesn't alter itself" do
      term = Term.from_string("x.n.n.n")
      old = Term.from_string("x.n")
      new = Term.from_string("y.l")
      new_term = term.replace(old, new)
      expect(new_term).to eq(Term.from_string("y.l.n.n"))
    end

    it "replaces old_term in self with new_term, doesn't alter itself" do
      term = Term.from_string("x")
      old = Term.from_string("x")
      new = Term.from_string("y.l")
      new_term = term.replace(old, new)
      expect(new_term).to eq(Term.from_string("y.l"))
    end

    it "replaces old_term in self with new_term, doesn't alter itself" do
      term = Term.from_string("x.n")
      old = Term.from_string("x.n")
      new = Term.from_string("y.l")
      new_term = term.replace(old, new)
      expect(new_term).to eq(Term.from_string("y.l"))
    end
  end
end

