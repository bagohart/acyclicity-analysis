require "spec_helper"
require_relative "../lib/rules.rb"
require "wrong/adapters/rspec"

#nocycle, noshare, noway, unequal
describe Rules do
  describe "#remove_redundancy" do
    it "removes no elements if no redundant elements contained" do
      f0 = Formula.new(:nocycle)
      f1 = Formula.from_strings(:noway, "x", "y")
      f2 = Formula.from_strings(:noway, "x.n", "y.n")
      f3 = Formula.from_strings(:noshare, "x.n.n", "y.n.n")
      fa = [f0, f1, f2, f3]

      result = Rules.remove_redundancy(fa)
      
      expect(result).to eq(fa)
    end

    it "repeatedly removes elements until no more redundant elements are contained, using a start formula multiple times" do
      f0 = Formula.new(:nocycle)
      f1 = Formula.from_strings(:noway, "x.n", "x")
      f2 = Formula.from_strings(:noway, "x.n.n", "x")
      f3 = Formula.from_strings(:noway, "a", "b")
      f4 = Formula.from_strings(:noway, "a.n", "b")
      f5 = Formula.from_strings(:noway, "a.n.n", "b")
      f6 = Formula.from_strings(:noway, "a.n.n.m", "b")
      fa = [f0, f1, f2, f3, f4, f5, f6]

      result = Rules.remove_redundancy(fa)
      
      expect(result).to eq([f0, f3])
    end

    it "repeatedly removes elements until no more redundant elements are contained, deriving from different start-formulas" do
      f0 = Formula.new(:nocycle)
      f1 = Formula.from_strings(:noway, "x.n.n", "x")
      f2 = Formula.from_strings(:noway, "x.n", "y")
      f3 = Formula.from_strings(:noway, "x.n.n", "y.n")
      f4 = Formula.from_strings(:noshare, "x.n.n", "y.n.n")
      fa = [f0, f1, f2, f3, f4]

      result = Rules.remove_redundancy(fa)
      
      expect(result).to eq([f0, f2, f3, f4])
    end
  end

  describe "#find_single_redundant_formula" do
    it "returns nil if no redundant formula is found" do
      f1 = Formula.from_strings(:noway, "x.n", "y")
      f2 = Formula.from_strings(:noway, "x.n.n", "y.n")
      fa = [f1, f2]

      rf = Rules.find_single_redundant_formula(fa)

      expect(rf).to be_nil
    end

    it "returns a single, but maybe not the first formula in the given array which is redundant. order: search through array 0..length, 0..length" do
      f1 = Formula.from_strings(:noshare, "x", "y")
      f2 = Formula.from_strings(:noshare, "y", "x")
      fa = [f1, f2]

      rf = Rules.find_single_redundant_formula(fa)

      expect(rf).to be(f2)
    end

    it "returns a single formula in the given array which is redundant" do
      f1 = Formula.from_strings(:noway, "x.n", "y")
      f2 = Formula.from_strings(:noway, "x.n.m", "y")
      fa = [f1, f2]

      rf = Rules.find_single_redundant_formula(fa)

      expect(rf).to be(f2)
    end
  end

  describe "#implies?" do
# derive from :nocycle
# :nocycle -> :nocycle
    it "derives from :nocycle to :nocycle, always true" do
      start = Formula.new(:nocycle)
      goal  = Formula.new(:nocycle)
      result = Rules.implies?(start, goal)
      expect(result).to be true
    end

# :nocycle -> :noshare
    it "derives from :nocycle to :noshare, always false" do
      result = Rules.implies?(Formula.new(:nocycle),           # start
                                       Formula.from_strings(:noshare, "x", "y")) # goal
      expect(result).to be false
    end

# :nocycle -> :noway
    it "derives from :nocycle to :noway, true" do
      result = Rules.implies?(Formula.new(:nocycle), 
                                       Formula.from_strings(:noway, "x.n", "x"))
      expect(result).to be true
    end

    it "derives from :nocycle to :noway, false" do
      result = Rules.implies?(Formula.new(:nocycle), 
                                       Formula.from_strings(:noway, "x.n", "x.n.n"))
      expect(result).to be false
    end

# :nocycle -> :unequal
    it "derives from :nocycle to :unequal, same as :nocycle to :noway, true" do
      result = Rules.implies?(Formula.new(:nocycle), 
                                       Formula.from_strings(:unequal, "x.n", "x"))
      expect(result).to be true
    end

    it "derives from :nocycle to :unequal, same as :nocycle to :noway, false" do
      result = Rules.implies?(Formula.new(:nocycle), 
                                       Formula.from_strings(:unequal, "x", "y"))
      expect(result).to be false
    end

# derive from :noshare
# :noshare -> :nocycle
    it "derives from :noshare to :nocycle, always false" do
      result = Rules.implies?(Formula.from_strings(:noshare, "x", "y"), 
                                       Formula.new(:nocycle))
      expect(result).to be false
    end

# :noshare -> :noshare
    it "derives from :noshare to :noshare, true" do
      result = Rules.implies?(Formula.from_strings(:noshare, "x", "y"), 
                                       Formula.from_strings(:noshare, "y", "x"))
      expect(result).to be true

      result = Rules.implies?(Formula.from_strings(:noshare, "x", "y"), 
                                       Formula.from_strings(:noshare, "x.n", "y"))
      expect(result).to be true

      result = Rules.implies?(Formula.from_strings(:noshare, "x", "y"), 
                                       Formula.from_strings(:noshare, "x", "y.n"))
      expect(result).to be true

      result = Rules.implies?(Formula.from_strings(:noshare, "x", "y"), 
                                       Formula.from_strings(:noshare, "x.n", "y.m"))
      expect(result).to be true

      result = Rules.implies?(Formula.from_strings(:noshare, "x", "y"), 
                                       Formula.from_strings(:noshare, "x.n", "y"))
      expect(result).to be true
    end

    it "derives from :noshare to :noshare, false" do
      result = Rules.implies?(Formula.from_strings(:noshare, "x.n", "y"), 
                                       Formula.from_strings(:noshare, "x", "y"))
      expect(result).to be false

      result = Rules.implies?(Formula.from_strings(:noshare, "x.n", "y"), 
                                       Formula.from_strings(:noshare, "x.m.n", "y"))
      expect(result).to be false

      result = Rules.implies?(Formula.from_strings(:noshare, "x", "y"), 
                                       Formula.from_strings(:noshare, "z.n", "y"))
      expect(result).to be false
    end

# :noshare -> :noway
    it "derives from :noshare to :noway, true" do
      result = Rules.implies?(Formula.from_strings(:noshare, "x", "y"), 
                                       Formula.from_strings(:noway, "x", "y"))
      expect(result).to be true

      result = Rules.implies?(Formula.from_strings(:noshare, "x", "y"), 
                                       Formula.from_strings(:noway, "x.n", "y.n"))
      expect(result).to be true
    end

    it "derives from :noshare to :noway, false" do
      result = Rules.implies?(Formula.from_strings(:noshare, "x.n", "y"), 
                                       Formula.from_strings(:noway, "x", "y"))
      expect(result).to be false

      result = Rules.implies?(Formula.from_strings(:noshare, "x", "y"), 
                                       Formula.from_strings(:noway, "z", "y"))
      expect(result).to be false

      result = Rules.implies?(Formula.from_strings(:noshare, "x", "y.n"), 
                                       Formula.from_strings(:noway, "x.n", "y"))
      expect(result).to be false
    end

# :noshare -> :unequal
    it "derives from :noshare to :unequal, true" do
      result = Rules.implies?(Formula.from_strings(:noshare, "x", "y"), 
                                       Formula.from_strings(:unequal, "x", "y"))
      expect(result).to be true

      result = Rules.implies?(Formula.from_strings(:noshare, "x", "y"), 
                                       Formula.from_strings(:unequal, "y.n", "x.m"))
      expect(result).to be true
    end

    it "derives from :noshare to :unequal, false" do
      result = Rules.implies?(Formula.from_strings(:noshare, "x.n", "y.n"), 
                                       Formula.from_strings(:unequal, "x", "y"))
      expect(result).to be false

      result = Rules.implies?(Formula.from_strings(:noshare, "x", "y.n"), 
                                       Formula.from_strings(:unequal, "x", "y"))
      expect(result).to be false
    end

# derive from :noway
# :noway -> :nocycle
    it "derives from :noway to :nocycle, always false" do
      result = Rules.implies?(Formula.from_strings(:noway, "x.n.n", "x"), 
                                       Formula.new(:nocycle))
      expect(result).to be false
    end

# :noway -> :noshare
    it "derives from :noway to :noshare, always false" do
      result = Rules.implies?(Formula.from_strings(:noway, "x", "y"), 
                                       Formula.from_strings(:noshare, "x", "y"))
      expect(result).to be false
    end

# :noway -> :noway
    it "derives from :noway to :noway, true" do
      result = Rules.implies?(Formula.from_strings(:noway, "x", "y"), 
                                       Formula.from_strings(:noway, "x.n.n", "y"))
      expect(result).to be true
    end

    it "derives from :noway to :noway, false" do
      result = Rules.implies?(Formula.from_strings(:noway, "x", "y"), 
                                       Formula.from_strings(:noway, "y", "x"))
      expect(result).to be false

      result = Rules.implies?(Formula.from_strings(:noway, "x", "y"), 
                                       Formula.from_strings(:noway, "x", "y.n"))
      expect(result).to be false

      result = Rules.implies?(Formula.from_strings(:noway, "x.n", "y"), 
                                       Formula.from_strings(:noway, "x", "y"))
      expect(result).to be false

      result = Rules.implies?(Formula.from_strings(:noway, "x", "y.n.n"), 
                                       Formula.from_strings(:noway, "x", "y"))
      expect(result).to be false

      result = Rules.implies?(Formula.from_strings(:noway, "x.m", "y.n.n"), 
                                       Formula.from_strings(:noway, "x.m.n.l", "y"))
      expect(result).to be false
    end

# :noway -> :unequal
    it "derives from :noway to :unequal, true" do
      result = Rules.implies?(Formula.from_strings(:noway,   "x", "y"), 
                                       Formula.from_strings(:unequal, "x", "y"))
      expect(result).to be true

      result = Rules.implies?(Formula.from_strings(:noway,   "x", "y"), 
                                       Formula.from_strings(:unequal, "y", "x"))
      expect(result).to be true

      result = Rules.implies?(Formula.from_strings(:noway,   "x", "y.n"), 
                                       Formula.from_strings(:unequal, "y.n", "x.n"))
      expect(result).to be true
    end

    it "derives from :noway to :unequal, false" do
      result = Rules.implies?(Formula.from_strings(:noway,   "x", "y"), 
                                       Formula.from_strings(:unequal, "x", "y.n"))
      expect(result).to be false

      result = Rules.implies?(Formula.from_strings(:noway,   "x.n", "y"), 
                                       Formula.from_strings(:unequal, "y", "x"))
      expect(result).to be false

      result = Rules.implies?(Formula.from_strings(:noway,   "x", "y"), 
                                       Formula.from_strings(:unequal, "z", "x"))
      expect(result).to be false

      result = Rules.implies?(Formula.from_strings(:noway,   "x", "y.n"), 
                                       Formula.from_strings(:unequal, "y", "x"))
      expect(result).to be false
    end

# derive from :unequal
    it "derives from :unequal, always false except identity" do
      result = Rules.implies?(Formula.from_strings(:unequal,   "x", "y"), 
                                       Formula.new(:nocycle))
      expect(result).to be false

      result = Rules.implies?(Formula.from_strings(:unequal,   "x", "y"), 
                                       Formula.from_strings(:noshare, "x", "y"))
      expect(result).to be false

      result = Rules.implies?(Formula.from_strings(:unequal,   "x", "y"), 
                                       Formula.from_strings(:noway, "x", "y"))
      expect(result).to be false

      result = Rules.implies?(Formula.from_strings(:unequal, "x", "y"), 
                                       Formula.from_strings(:unequal, "x", "y"))
      expect(result).to be true

      result = Rules.implies?(Formula.from_strings(:unequal, "x", "y"), 
                                       Formula.from_strings(:unequal, "y", "x"))
      expect(result).to be true
    end
  end
end

