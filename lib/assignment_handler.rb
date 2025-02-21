require_relative "formula.rb"

class AssignmentHandler
#verdacht: koennte versehentlich dinge 'beweisen' wie noway(x, x.n). vermutung: muss mit xor behandelt werden
#oder: diesen fall einfach separat rausfischen. daraus kann eh nichts gutes entstehen o_O
#einzige ausnahme: temp = null; temp.n !-> temp.n.n ?
  def assign_new(input, left_op)
    fail_case = input.select { |f| f.predicate != :nocycle && f.predicate != false && (left_op <= f.first && left_op <= f.second) }
    unless fail_case.empty?
      d = input
      g = [Formula.new(:false)]
      return d, g
    end
    deleted = input.select { |f| f.predicate != :nocycle && f.predicate != false && (left_op <= f.first || left_op <= f.second) }
    generated = []
    return deleted, generated
  end

  def assign_var(input, left_op, right_op)
    simple_replace(input, left_op, right_op)
  end

  def simple_replace(input, left_op, right_op)
    deleted = input.select { |f| f.predicate != :nocycle && f.predicate != :false && (left_op <= f.first || left_op <= f.second) }
    generated = deleted.map { |f| f.replace(left_op, right_op) }
    return deleted, generated
  end

  # other_fields are of type Field
  def assign_field(input, left_op, right_op, other_fields)
    new_formula = derive_new_noway_statement(left_op, right_op)
    d1, g1 = simple_replace(input, left_op, right_op)
    d2, g2 = assign_field_noway(input, left_op, right_op, other_fields)
    d3, g3 = assign_field_noshare(input, left_op, right_op, other_fields)
    return d1+d2+d3, g1+g2+g3+[new_formula]
  end

  # from x.n = y derive :noway(y, x)
  def derive_new_noway_statement(left_op, right_op)
    Formula.new(:noway, right_op, Term.new(left_op.var))
  end

  def assign_field_noway(input, left_op, right_op, other_fields)
    deleted = (input.select { |f| f.predicate == :noway && f.first < left_op }) # || []
    generated = (deleted.map { |f| noway_field_assign_replacement(f, right_op, other_fields) }.flatten!) || []
    return deleted, generated
  end

  def noway_field_assign_replacement(formula, right_op, other_fields)
    assert { formula.is_a? Formula }
    generated = other_fields.map { |field| Formula.new(:noway,
                                                       Term.new(formula.first.var, *(formula.first.accessed_fields + [field])),
                                                       formula.second) }
    generated << Formula.new(:noway, right_op, formula.second)
    generated << Formula.new(:unequal, formula.first, formula.second)
  end

  def assign_field_noshare(input, left_op, right_op, other_fields)
    deleted = input.select { |f| f.predicate == :noshare && (f.first < left_op || f.second < left_op) && !(f.first < left_op && f.second < left_op) }
    generated = (deleted.map { |f| noshare_field_assign_replacement(f, left_op, right_op, other_fields) }.flatten!) || []
    return deleted, generated
  end

  def noshare_field_assign_replacement(formula, left_op, right_op, other_fields)
    # beide < left_op sollte nicht vorkommen. wird (???) in assign_field_noshare ausgeschlossen
    case
    when formula.first < left_op then changed = formula.first; not_changed = formula.second
    when formula.second < left_op then changed = formula.second; not_changed = formula.first
    end
    generated = other_fields.map { |field| Formula.new(:noshare,
                                                       Term.new(changed.var, *changed.accessed_fields + [field]),
                                                       not_changed) }
    generated << Formula.new(:noshare, right_op, not_changed)
    generated << Formula.new(:noway, not_changed, changed)
  end
end

