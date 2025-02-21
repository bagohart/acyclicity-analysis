require "java"
require_relative "soot-trunk.jar"

java_import Java::Soot.Unit
java_import Java::Soot.tagkit.Tag
java_import Java::Soot.Value
java_import Java::Soot.Type
java_import Java::Soot.RefType
java_import Java::Soot.jimple.AssignStmt
java_import Java::Soot.jimple.internal.JNewExpr
java_import Java::Soot.jimple.NullConstant

module SootHelper
  class UnitIDTag
    include Tag

    def initialize(unit_ID)
      @unit_ID = unit_ID
    end

    def getName
      "unit_ID"
    end

    def getValue
      @unit_ID
    end     

    def to_s
      @unit_ID.to_s
    end
  end

  def SootHelper.add_IDs_to_cfg_units(cfg)
    cfg_it = cfg.iterator
    unit_id = 0
    while cfg_it.hasNext
      current_unit = cfg_it.next
      cur_unit_id = "#{unit_id}: #{current_unit.toString}"
      unit_tag = UnitIDTag.new(cur_unit_id)
      current_unit.addTag(unit_tag)
      unit_id += 1
    end
  end

  def self.has_relevant_fields?(soot_value, relevant_fields)
    field_type = soot_value.getType
    return false unless field_type.is_a? RefType
    fields = field_type.getSootClass.getFields.iterator.map { |field| field.getName }
    case fields & relevant_fields
    when [] then false
    else true
    end
  end

  def self.unit_to_string(unit, verbose)
    unless unit.is_a?(AssignStmt)
      return unit.toString
    end

    case verbose
    when true then unit.toString
    else
      left = if unit.getLeftOp.is_a?(InstanceFieldRef)
               "#{unit.getLeftOp.getBase.toString}.#{unit.getLeftOp.getField.getName}"
             else
               unit.getLeftOp.toString
             end
      right = if unit.getRightOp.is_a?(InstanceFieldRef)
               "#{unit.getRightOp.getBase.toString}.#{unit.getRightOp.getField.getName}"
             else
               unit.getRightOp.toString
             end
      "#{left} = #{right}"
    end
  end

  def SootHelper.num_same_type_fields(soot_object) 
    left_operand_type = case soot_object
                        when AssignStmt then soot_object.getLeftOp.getType
                        when Value      then soot_object.getType
                        when Type       then soot_object
                        else binding.pry; raise "Unknown soot_object!"
                        end
    return count_same_type_fields(left_operand_type)
  end

  #diese Methode ist nicht für die Öffentlichkeit
  def SootHelper.count_same_type_fields(type)
    # REVIEW: Ich glaube, RefType sind genau alle Java-Klassen. Sollte ich wohl mal überprüfen
    return 0 unless type.is_a?(RefType) 
    counter = 0
    it = type.getSootClass.getFields.iterator
    while it.hasNext
      field = it.next
      field_type = field.getType
      counter += 1 if type.equals(field_type)
    end
    counter
  end

  def SootHelper.get_relevant_fields(type)
    return [] unless type.is_a?(RefType)
    relevant_fields = type.getSootClass.getFields.iterator.select do |field|
      field_type = field.getType
      #next field_type.equals(field_type) && $fields_to_analyse.include?(field.getName) # da muss ich noch drumherum coden
      next $fields_to_analyse.include?(field.getName)
    end
  end

  def SootHelper.assign_stmt_using_new?(assign_stmt)
    assert { assign_stmt.is_a?(AssignStmt) }
    right_operand = assign_stmt.getRightOp
    right_operand.is_a?(JNewExpr)
  end

  def SootHelper.null?(soot_obj)
    NullConstant.v.equals(soot_obj)
  end

  def SootHelper.soot_obj_to_string(soot_obj)
    case soot_obj
    when Symbol     then soot_obj.to_s
    when Value      then soot_obj.toString
    when SootField  then soot_obj.toString
    end
  end
end

