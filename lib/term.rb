require "soot_helper.rb"

# provides a readable way to initialize a term, which can be used to construct formulas
class Term
  attr_accessor :var
  attr_accessor :accessed_fields

  def self.from_string(term_as_str)
    var_str, *fields_str = term_as_str.split('.')
    lvar = LocalVar.new(var_str.to_sym)
    fields = fields_str.map { |f| Field.new(f.to_sym) }
    Term.new(lvar, *fields)
  end

  def initialize(local_var, *accessed_fields)
    assert { local_var.is_a?(LocalVar) && accessed_fields.all? { |f| f.is_a?(Field) } }
    @var = local_var
    @accessed_fields = accessed_fields
    freeze
  end

  # checks if this term <= other_term
  # x.n <= x.n.m => true
  # x.n <= x.n => true
  # x.n <= x.p => false
  # x.n <= x => false
  def prefix_of?(other_term)
    @var == other_term.var && self.class.prefix_of_accessed_fields?(@accessed_fields, other_term.accessed_fields)
  end
  alias :<= :prefix_of?

  def >=(other_term)
    other_term <= self
  end

  # same as prefix_of?, except for equality: x.n <= x.n => false
  def real_prefix_of?(other_term)
    self != other_term && prefix_of?(other_term)
  end
  alias :< :real_prefix_of?

  def >(other_term)
    other_term < self
  end

  def self.prefix_of_accessed_fields?(prefix, fields)
    case
    when prefix.empty? then true
    when fields.empty? then false
    else prefix.first == fields.first && prefix_of_accessed_fields?(prefix[1..-1], fields[1..-1])
    end
  end

  # precondition old_term_part <= self, otherwise useless behaviour
  def replace(old_term_part, new_term_part)
    new_var = new_term_part.var
    new_fields = new_term_part.accessed_fields + @accessed_fields[old_term_part.accessed_fields.length..-1]
    Term.new(new_var, *new_fields)
  end

  def ==(other)
    other.instance_of?(self.class) && @var == other.var && @accessed_fields == other.accessed_fields
  end
  alias :eql? :==

  def to_s
    ([@var] + @accessed_fields).join(".")
  end
end

