require "pry"

require_relative "formula.rb"
require_relative "acyclic_heap_analysis.rb"
require_relative "protocol.rb"

require_relative "initialiser.rb"
require_relative "assignment_handler.rb"
require_relative "invariant_handler.rb"

java_import Java::Soot.Main
java_import Java::Soot.Scene
java_import Java::Soot.PhaseOptions
java_import Java::Soot.options.Options
java_import Java::Soot.SootClass
java_import Java::Soot.PackManager

java_import Java::Soot.toolkits.scalar.BackwardFlowAnalysis
java_import Java::Soot.BodyTransformer
java_import Java::Soot.Transform
java_import Java::Soot.PackManager
java_import Java::Soot.toolkits.graph.ExceptionalUnitGraph
java_import Java::Soot.toolkits.scalar.ArraySparseSet

# 2. Versuch
def analyse(class_name, methods_to_analyse)
  #setup_soot(".:/usr/lib/jvm/default-java/jre/lib/rt.jar:./javax-crypto.jar:./required_jar/:../java_examples/wrapped_list/")
#  setup_soot(".:/usr/lib/jvm/default-java/jre/lib/rt.jar:./javax-crypto.jar:./required_jar/:../java_examples/wbt/")
  setup_soot($soot_class_path)

  soot_class = load_soot_class_and_support_classes(class_name)
  soot_class.getMethods.select { |soot_method| methods_to_analyse.include?(soot_method.getName) }.each do |soot_method|
    control_flow_graph, analysis = analyse_soot_method(soot_method)   
    result_array = result_to_string_array(control_flow_graph, analysis)
    puts "\nCOMPLETE ANALYSIS OF METHOD: #{class_name}.#{soot_method.getName}:"
    result_array.each { |s| puts s }
  end
end

def setup_soot(soot_class_path)
  Scene.v.setSootClassPath(soot_class_path)
  Options.v.set_verbose(true) if $soot_verbose
end

# REVIEW: unknown behaviour if called twice with different classes
def load_soot_class_and_support_classes(class_name)
  soot_class = Scene.v.loadClassAndSupport(class_name)
  soot_class.setApplicationClass()
  Scene.v.loadNecessaryClasses() # This is cargo-cult programming. This statement has to be there after loadClassAndSupport(), no idea why.
  soot_class
end

def analyse_method(soot_class, method_name)
  soot_method = soot_class.getMethodByName(method_name)
  analyse_soot_method(soot_method)
end

def analyse_soot_method(soot_method)
  method_body = soot_method.retrieveActiveBody
  eliminate_NOPs!(method_body)
  simplify_thing!(method_body)
  unit_graph = ExceptionalUnitGraph.new(method_body)
  analysis = AcyclicHeapAnalysis.new(unit_graph, $relevant_fields, Initialiser.new, AssignmentHandler.new, InvariantHandler.new)
  Logger.instance.log("ANALYSIERE JETZT #{soot_method.getName()}") if $debug_level >= $LOG_ANALYSIS
  puts method_body
before = Time.new
  analysis.doAnalysis
after = Time.new
puts "#{soot_method.getName()} Time = " 
puts (after - before)
  return unit_graph, analysis
end

def eliminate_NOPs!(method_body)
  PackManager.v.getTransform("jb.ne").apply(method_body) # "jb.ne" = jimple body, nop eliminator
end

#REVIEW name
def simplify_thing!(method_body) 
  PackManager.v.getTransform("jb.ulp").apply(method_body) # a, ulp, lp wahrscheinlich eins davon
end

def result_to_string_array(control_flow_graph, analysis)
  string_array = []
  control_flow_graph.iterator.each do |unit|
    string_array.concat(unit_result_to_string_array(unit, analysis))
    string_array << "\n"
  end
  string_array.pop # remove trailing "\n"
  string_array
end

def unit_result_to_string_array(unit, analysis)
  string_array = []
before_reduce = analysis.getFlowAfter(unit)
    after_reduce = Rules.remove_redundancy(before_reduce.to_a) 
    after_reduce.delete_if { |f| f.predicate != :nocycle && [f.first.var.var, f.second.var.var].any? { |var| var.is_a?(NullConstant) } }
  #string_array << "in: #{after_reduce.map { |f| f.to_s }.join(", ")}"
  string_array << "in: #{analysis.getFlowBefore(unit).map { |f| f.to_s }.join(", ")}"
#  string_array << unit.toString # REVIEW: kA wieso das nicht crasht, laut Doku muss man der Methode noch einen Parameter übergeben
  string_array << SootHelper.unit_to_string(unit, $soot_verbose)
  #string_array << "out: #{analysis.getFlowAfter(unit).map { |f| f.to_s }.join(", ")}"
  string_array << "out: #{after_reduce.map { |f| f.to_s }.join(", ")}"
  string_array
end

