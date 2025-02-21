require "wrong"
include Wrong

require_relative "soot_helper.rb"
 
# There are only 4 types of allowed formulas:
# nocycle
# noshare(a, b)
# noway  (a, b)
# unequal(a, b)
# false
class Formula
  attr_accessor :predicate
  attr_accessor :first
  attr_accessor :second

  def self.from_strings(predicate, *terms)
    Formula.new(predicate.to_sym, *(terms.map { |t| Term.from_string(t) }))
  end

  def initialize(predicate, *terms)
    @predicate = predicate
    if(@predicate != :nocycle && @predicate != :false)
      assert { terms.length == 2 }
      @first, @second = *terms
      assert { @first.is_a?(Term) && @second.is_a?(Term) }
    end
    freeze
  end

  def ==(other)
    other.instance_of?(self.class) && @predicate == other.predicate && @first == other.first && @second == other.second
  end
  alias :eql? :==

  def hash
    to_s.length
  end

  def to_s
    case @predicate
    when :nocycle then "[:NOCYCLE]"
    when :false then "[:FALSE]"
    else               "[:#{predicate.upcase}(#{@first}, #{@second})]"
    end
  end

  def replace(old_term, new_term)
    raise "replace without job!" unless old_term <= @first || old_term <= @second
    new_first  =  old_term <= @first ? @first.replace(old_term, new_term) : @first
    new_second =  old_term <= @second ? @second.replace(old_term, new_term) : @second
    Formula.new(@predicate, new_first, new_second)
  end
end

