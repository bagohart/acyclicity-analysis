require "spec_helper"
require_relative "../lib/formula.rb"
require "wrong/adapters/rspec"

describe Formula do
  describe "#initialize" do
    it "creates a formula using given objects and freezes it" do
      f1 = Formula.new(:nocycle)
      t1 = Term.from_string("x.n.n.n")
      t2 = Term.from_string("x.n")
      f2 = Formula.new(:noway, t1, t2)
      t3 = Term.from_string("y.n.m")
      f3 = Formula.new(:noshare, t3, t3)

      expect(f1.frozen?).to be true
      expect(f1.predicate).to eq(:nocycle)

      expect(f2.predicate).to eq(:noway)
      expect(f2.first).to be(t1)
      expect(f2.second).to be(t2)

      expect(f3.predicate).to eq(:noshare) 
      expect(f3.first).to be(t3) 
      expect(f3.second).to be(t3)
    end
  end

  describe "#==" do
    it "compares two formulas, example for two formulas with Symbols only" do
      f1 = Formula.from_strings(:noway, "x.n.n", "x.n")
      f2 = Formula.from_strings(:noway, "x.n.n", "x.n")
      f3 = Formula.from_strings(:noshare, "x.n.n", "x.n")
      f4 = Formula.from_strings(:noway, "x.n.n.n", "x.n")

      expect(f1).to eq(f2)
      expect(f1).to_not eq(f3)
      expect(f1).to_not eq(f4)
      expect(f3).to_not eq(f4)
    end

    it "compares two terms, example for Soot objects" do
      #TODO
    end
  end

  describe "#replace" do
    it "replaces old_term in both first and second with new_term" do
      f = Formula.from_strings(:noway, "x.n.m", "x.n.l")
      f1 = f.replace(Term.from_string("x.n"),   Term.from_string("y"))
      f2 = f.replace(Term.from_string("x.n.m"),   Term.from_string("y"))
      f3 = f.replace(Term.from_string("x.n"),   Term.from_string("z.n"))
      f4 = f.replace(Term.from_string("x.n.m"),   Term.from_string("z.n"))
      f5 = f.replace(Term.from_string("x"),   Term.from_string("z.n.l"))
      f6 = f.replace(Term.from_string("x"),   Term.from_string("z"))
      expect(f1).to eq(Formula.from_strings(:noway, "y.m", "y.l"))
      expect(f2).to eq(Formula.from_strings(:noway, "y", "x.n.l"))
      expect(f3).to eq(Formula.from_strings(:noway, "z.n.m", "z.n.l"))
      expect(f4).to eq(Formula.from_strings(:noway, "z.n", "x.n.l"))
      expect(f5).to eq(Formula.from_strings(:noway, "z.n.l.n.m", "z.n.l.n.l"))
      expect(f6).to eq(Formula.from_strings(:noway, "z.n.m", "z.n.l"))
    end
  end

  describe "#to_s" do
    it "returns string representation of formula" do
      str = Formula.from_strings(:noway, "x.n", "y").to_s
      expect(str).to eq("[:NOWAY(x.n, y)]")
    end
  end
end

#alles ab hier weg
#require "spec_helper"
#require_relative "../lib/formula.rb"
#require "wrong/adapters/rspec"
#
#describe Formula do
#  describe "#initialize" do
#    it "initializes an Formula by storing a given Array" do
#      formula = Formula.new([:nocycle])
#      assert { formula.sexpr == [:nocycle] }
#    end
#  end
#      
#  describe "#deep_copy" do
#    it "creates a deep copy of its stored value, example nocycle" do
#      formula = Formula.new([:nocycle])
#      new_sexpr = formula.deep_copy
#      assert { formula.sexpr == new_sexpr }
#      deny { formula.sexpr.equal?(new_sexpr) }
#    end
#     
#    it "creates a deep copy of its stored value, example noway" do
#      formula = Formula.new([:noway, [:a, :b]])
#      new_sexpr = formula.deep_copy
#      assert { formula.sexpr == new_sexpr }
#      deny { formula.sexpr.equal?(new_sexpr) }
#      deny { formula.sexpr[1].equal?(new_sexpr[1]) }
#    end
#   end
#
#  describe "#predicate" do
#    it "returns the predicate stored by the Formula, which is always at the start of the array, example nocycle" do
#      formula = Formula.new([:nocycle])
#      assert { formula.sexpr[0] == :nocycle }
#    end
#
#    it "returns the predicate stored by the Formula, which is always at the start of the array, example noway" do
#      formula = Formula.new([:noway, [:a, :b]])
#      assert { formula.sexpr[0] == :noway }
#    end
#  end
#
#  describe "#first" do
#   it "returns the first element of the Formula, example noway" do
#     formula = Formula.new([:noway, [:a, :b]])
#     first = formula.first()
#     assert { first == :a }
#   end
#  end
#
#  describe "#second" do
#    it "returns the second element of the Formula, example noway" do
#      formula = Formula.new([:noway, [:a, :b]])
#      second = formula.second()
#      assert { second == :b }
#    end
#  end
#
##  describe "#to_s" do
##    it "returns a string describing the Formula, example nocycle" do
##      formula = Formula.new([:nocycle])
##      string = formula.to_s
##      assert { string == "[:nocycle]" }
##    end
##
##    it "returns a string describing the Formula, example noway" do
##      formula = Formula.new([:noway, [:a, :b]])
##      string = formula.to_s
##      assert { string == "[:noway, [:a, :b]]" }
##    end
##  end
#end
#
