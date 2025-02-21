require_relative "formula.rb"

class Initialiser
  def new_initial_flow
    []
  end

  def entry_initial_flow
    [Formula.new(:nocycle)]
  end
end

