require "java"
require_relative "soot-trunk.jar"

require_relative "formula.rb"
require_relative "protocol.rb"
require_relative "formula_set.rb"
require_relative "term.rb"
require_relative "local_var.rb"
require_relative "field.rb"


java_import Java::Soot.toolkits.scalar.BackwardFlowAnalysis
java_import Java::Soot.jimple.internal.JNewExpr
java_import Java::Soot.jimple.InstanceFieldRef
java_import Java::Soot.jimple.NullConstant

class AcyclicHeapAnalysis < BackwardFlowAnalysis
  def initialize(control_flow_graph, relevant_fields, initialiser, assignment_handler, invariant_handler)
    super(control_flow_graph)
    @cfg = control_flow_graph
    @relevant_fields = relevant_fields # those are strings!
    @initialiser = initialiser
    @assignment_handler = assignment_handler
    @invariant_handler = invariant_handler
    @merge_counter = 0
    @flowthrough_counter = 0
    SootHelper.add_IDs_to_cfg_units(control_flow_graph)
    #@unit_formula_dict = initialize_unit_formula_dictionary(->{ [] })
    @unit_formula_dict = initialize_unit_formula_dictionary { [] }
  end

  def initialize_unit_formula_dictionary(&initial_value)
    hash = Hash.new
    @cfg.iterator.each do |unit|
      hash[unit.getTag("unit_ID").getValue] = initial_value.call
    end
    hash
  end

  def entryInitialFlow
    Logger.instance.log("enter entryInitialFlow") if $debug_level >= $LOG_ALL
    array_result = @initialiser.entry_initial_flow
    set_result = FormulaSet.new(array_result)
    Logger.instance.log("exit entryInitialFlow, result=#{set_result}") if $debug_level >= $LOG_ALL
    set_result
  end

  def newInitialFlow
    Logger.instance.log("enter newInitialFlow") if $debug_level >= $LOG_ALL
    array_result = @initialiser.new_initial_flow
    set_result = FormulaSet.new(array_result)
    Logger.instance.log("exit newInitialFlow, result=#{set_result}") if $debug_level >= $LOG_ALL
    set_result
  end

  def copy(source, dest)
    Logger.instance.log("enter copy, source=#{source}, dest=#{dest}") if $debug_level >= $LOG_ALL
    dest.clear
    source.each { |formula| dest.add(formula) }
    Logger.instance.log("exit copy, source=#{source}, dest=#{dest}") if $debug_level >= $LOG_ALL
  end

  def flowThrough(formula_set_input, unit, formula_set_output)
    @flowthrough_counter += 1
$fc = @flowthrough_counter
    input = formula_set_input.to_ruby_array
    input2 = cleanup(input)
    Logger.instance.log("Betrete flowThrough #{@flowthrough_counter}. Input=#{input2.join(", ")} Unit:\n#{SootHelper.unit_to_string(unit, $soot_verbose)}") if $debug_level >= $LOG_ANALYSIS
    output = flow_through_using_ruby_arrays(input2, unit)
    formula_set_output.copy_from_ruby_array(output)
    @unit_formula_dict[unit.getTag("unit_ID").getValue] << formula_set_output
    @last_visited_unit = unit.getTag("unit_ID").getValue
    Logger.instance.log("Verlasse flowThrough. Output=#{formula_set_output}\n\n") if $debug_level >= $LOG_ANALYSIS
  end

  def cleanup(input)
    ca = Rules.remove_redundancy(input) 
    ca.delete_if { |f| f.predicate != :nocycle && [f.first.var.var, f.second.var.var].any? { |var| var.is_a?(NullConstant) } }
  end

  def flow_through_using_ruby_arrays(input, unit)
    #if unit.is_a?(AssignStmt) && SootHelper.has_relevant_fields?(unit.getLeftOp, @relevant_fields) && (!unit.getLeftOp.is_a?(InstanceFieldRef) || unit.getLeftOp.getBase.getType == unit.getLeftOp.getField.getType)
    if unit.is_a?(AssignStmt) && SootHelper.has_relevant_fields?(unit.getLeftOp, @relevant_fields) 
      flow_through_assign(input, unit)
    else
      input
    end
  end

  def flow_through_assign(input, assign_stmt)
    d = []; g = []
    #other_fields = @relevant_fields.map { |f_str| Field.new(f_str.to_sym) }
    if assign_stmt.getRightOp.is_a?(JNewExpr) # jimple: this is not access to a field, always a temporary variable
      left_op = Term.new(LocalVar.new(assign_stmt.getLeftOp))
      d,g = @assignment_handler.assign_new(input, left_op)
    elsif assign_stmt.getLeftOp.is_a?(InstanceFieldRef) && @relevant_fields.include?(assign_stmt.getLeftOp.getField.getName)
      other_fields = find_other_fields(@relevant_fields, assign_stmt.getLeftOp)
      left_op = Term.new(LocalVar.new(assign_stmt.getLeftOp.getBase), Field.new(assign_stmt.getLeftOp.getField))
      right_op = Term.new(LocalVar.new(assign_stmt.getRightOp))
#binding.pry if $dang
      d,g = @assignment_handler.assign_field(input, left_op, right_op, other_fields)
    else # var = temp. can't be var.field if called correctly from flow_through_using_ruby_arrays. doch, kann es wohl: this.head
      #left_op = Term.new(LocalVar.new(assign_stmt.getLeftOp))
      left_op = case assign_stmt.getLeftOp
                when InstanceFieldRef    then Term.new(LocalVar.new(assign_stmt.getLeftOp.getBase), Field.new(assign_stmt.getLeftOp.getField))
                when Local, NullConstant then Term.new(LocalVar.new(assign_stmt.getLeftOp))
                else raise "this should never happen"
                end
      right_op = case assign_stmt.getRightOp
                 when InstanceFieldRef    then Term.new(LocalVar.new(assign_stmt.getRightOp.getBase), Field.new(assign_stmt.getRightOp.getField))
                 when Local, NullConstant then Term.new(LocalVar.new(assign_stmt.getRightOp))
                 else raise "this should never happen"
                 end
      d,g = @assignment_handler.assign_var(input, left_op, right_op)
    end
    (input - d) + g
  end

  def find_other_fields(relevant_fields, left_op)
    assert { left_op.is_a? InstanceFieldRef }
    fields = relevant_fields - [left_op.getField.getName]
    existing_fields = left_op.getBase.getType.getSootClass.getFields.map { |f| f.getName }
    fields = fields.select { |f_str| existing_fields.include?(f_str) }
    fields = fields.map { |f_str| Field.new(f_str.to_sym) }
    fields
  end

  def merge(formula_set_input1, formula_set_input2, formula_set_output)
    @merge_counter += 1
    Logger.instance.log("BETRETE MERGE #{@merge_counter}. Input1={#{formula_set_input1}} Input2={#{formula_set_input2}}") if $debug_level >= $LOG_ANALYSIS
    input1 = formula_set_input1.to_ruby_array
    input2 = formula_set_input2.to_ruby_array
    input_old = case @unit_formula_dict[@last_visited_unit][-2] # Zugriff auf den Wert der letzten Iteration. [-1] liefert den aktuellen Wert, den kriegen wir sowieso
                when nil then []
                else @unit_formula_dict[@last_visited_unit][-2].to_ruby_array
                end
    Logger.instance.log("Inputold={#{input_old.join(", ")}}")
    output = @invariant_handler.process(input1, input2, input_old, @relevant_fields)
    formula_set_output.copy_from_ruby_array(output)
    Logger.instance.log("Verlasse merge. Output=#{formula_set_output}\n\n") if $debug_level >= $LOG_ANALYSIS
  end
end

