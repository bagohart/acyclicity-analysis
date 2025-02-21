require "rubygems"
require "bundler/setup"

require "wrong"
include Wrong

module Rules
  # for all f, f' in input: if f => f' then f' is removed
  def self.remove_redundancy(formula_array)
    output = Array.new(formula_array)
    loop do
      redundant_formula = find_single_redundant_formula(output)
      return output if redundant_formula.nil?
      output.delete(redundant_formula) 
    end
  end

  def self.find_single_redundant_formula(formula_array)
    #REVIEW geht das einfacher???
    formula_array.each do |start|
      formula_array.each { |goal| return goal if start != goal && self.implies?(start, goal) }
    end
    nil
  end

  # takes 2 Formulas. Checks if goal can be deduced using the following rules: (f1 => f1 holds always)
  # :nocycle => x.n !-> x
  # x !-><- y => y !-><- x
  # x !-><- y => x !-><- y.n
  # x !-> y => x.n !-> y
  # x !-> y.n => x !-> y
  # x !-><- y => x != y
  # x !-> y => x != y
  # x !-> y => y != x # complete???
  def self.implies?(start, goal)
    assert { start.is_a?(Formula) && goal.is_a?(Formula) }
    if start.predicate == :false
      return true
    elsif goal.predicate == :false
      return false
    end
    rule = @derivation_rules[[start.predicate, goal.predicate]]
    args = []
    args.concat([start.first, start.second]) if start.predicate != :nocycle
    args.concat([goal.first,  goal.second])  if goal.predicate  != :nocycle
    rule.call(*args)
  end

  # Abbreviations
  # ns = noshare
  # nw = noway
  # ue = unequal
  # g = goal
  # s = start
  # <, <= overridden to mean (real) prefix of 
  @derivation_rules = {
    # derive from :nocycle
    [:nocycle, :nocycle] => ->{ true },
    [:nocycle, :noshare] => ->(ns1, ns2) { false },
    [:nocycle,   :noway] => ->(nw1, nw2) { nw2 < nw1 },
    #[:nocycle, :unequal] => ->(ue1, ue2) { false }, #stimmt nicht, muss noway sein o_O

    # derive from :noshare
    [:noshare, :nocycle] => ->(ns1, ns2) { false },
    [:noshare, :noshare] => ->(s1, s2, g1, g2) { s1 <= g1 && s2 <= g2 ||
                                                 s1 <= g2 && s2 <= g1   },
    [:noshare,   :noway] => ->(ns1, ns2, nw1, nw2) { (ns1 <= nw1 && ns2 <= nw2) || 
                                                     (ns2 <= nw1 && ns1 <= nw2)   },

    # derive from :noway
    [:noway, :nocycle] => ->(nw1, nw2) { false },
    [:noway, :noshare] => ->(nw1, nw2, ns1, ns2) { false },
    [:noway,   :noway] => ->(s1, s2, g1, g2) { s1 <= g1 && s2 == g2 },

    # derive from :unequal
    [:unequal, :nocycle] => ->(ue1, ue2) { false },
    [:unequal, :noshare] => ->(ue1, ue2, ns1, ns2) { false },
    [:unequal,   :noway] => ->(ue1, ue2, nw1, nw2) { false },
    [:unequal, :unequal] => ->(s1, s2, g1, g2) { s1 == g1 && s2 == g2 ||
                                                  s1 == g2 && s2 == g1    }
  }
#  @derivation_rules[[:nocycle, :unequal]] = @derivation_rules[[:nocycle, :noway]]
  @derivation_rules[[:nocycle, :unequal]] = ->(ue1, ue2) { ue1 < ue2 || ue2 < ue1 }
  @derivation_rules[[:noshare, :unequal]] = @derivation_rules[[:noshare, :noway]]
  @derivation_rules[[:noway,   :unequal]] = ->(nw1, nw2, ue1, ue2) { @derivation_rules[[:noway, :noway]][nw1, nw2, ue1, ue2] || 
                                                                     @derivation_rules[[:noway, :noway]][nw1, nw2, ue2, ue1]   }
end

