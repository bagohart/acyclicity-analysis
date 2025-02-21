require_relative "formula.rb"
require_relative "rules.rb"

class InvariantHandler
  def process(input1, input2, inputold, relevant_fields)
    return input1 if input2.empty?
    input = input1 | input2 | inputold
    process_merged_input(input, relevant_fields)
  end

  def process_merged_input(input0, relevant_fields)
    input_temp = Rules.remove_redundancy(input0)
    input1 = simplify_noshare_formulas(input_temp, relevant_fields)

    #input1 = simplify_noshare_formulas(input0, relevant_fields)
    input2 = create_noshare_invariants(input1, relevant_fields)
    input3 = create_unequal_invariant(input2)
    input4 = Rules.remove_redundancy(input3)
  end

  def create_unequal_invariant(input)
    unequal_formulas = input.select { |f| f.predicate == :unequal }
    # don't delete formulas here. rely on remove_redundancy later instead.
    new_invariants = []
    unequal_formulas.each do |f|
      greater = unequal_formulas.find { |other| f != other && f != Formula.new(:unequal, other.second, other.first) && ((f.first <= other.first && f.second <= other.second) || (f.first <= other.second && f.second <= other.first)) }
      next if greater.nil?
      if f.first < greater.first || f.first < greater.second
        new_invariants << Formula.new(:noway, f.first, f.second)
      elsif f.second < greater.first || f.second < greater.second
        new_invariants << Formula.new(:noway, f.second, f.first)
      else
        raise "this shouldn't ever happen"
      end
    end
    input + new_invariants
  end

  def simplify_noshare_formulas(input, relevant_fields)
    output = Array.new(input) 
    deleted = input.select { |f| f.predicate == :noshare }
    generated = deleted.map { |f| noshare_simplified(f, relevant_fields) }
    (output - deleted) + generated
  end

  def noshare_simplified(f, relevant_fields)
    new_fields = [Array.new(f.first.accessed_fields), Array.new(f.second.accessed_fields)]
    new_fields.each { |accessed_fields| accessed_fields.pop while !accessed_fields.empty? && relevant_fields.include?(accessed_fields.last.to_s) }
    Formula.new(:noshare, Term.new(f.first.var, *new_fields[0]), Term.new(f.second.var, *new_fields[1]))
  end

  def create_noshare_invariants(input, relevant_fields)
    noway_formulas = input.select { |f| f.predicate == :noway }
    output = input
    loop do
      chain = find_chain(noway_formulas)
      return output if chain.nil?
      noway_formulas -= chain
      new_formula = create_invariant_from_chain(chain, relevant_fields)
      output = (output - chain) + [new_formula]
    end
  end

  def find_chain(noway_formulas)
    sorted = noway_formulas.sort_by { |f| f.second.accessed_fields.length }
    sorted.each do |f|
      chain = sorted.select { |cf| f.first <= cf.first && f.second < cf.second }
      return [f] + chain unless chain.empty?
    end
    nil
  end

  def create_invariant_from_chain(chain, relevant_fields)
    first_formula = chain.first
    f = Formula.new(:noshare, first_formula.first, first_formula.second)
    noshare_simplified(f, relevant_fields)
  end
end

