# This file contains an alternative way to run the analysis, which is recommended by the Soot documentation as the standard way
# It uses the BodyTransformer classes and lets Soot run its own process.
# Not used any more, because it makes debugging harder.

#Analysiert alle Dateien in dem angegebenen Verzeichnis
def analyse_discarded(directory_input, directory_output, method_names=[])
  $method_names = method_names
  transformer = Transformer.new
  transform = Transform.new("jtp.acyclicHeapAnalysis", transformer)
  PackManager.v().getPack("jtp").add(transform)
  soot_arguments = [
    "-process-dir",
    directory_input,
    "-d",
    directory_output,
    "-cp",
    ".:/usr/lib/jvm/default-java/jre/lib/rt.jar:./javax-crypto.jar:./required_jar/"
  ]
  puts "Rufe Soot auf mit folgenden Argumenten: #{soot_arguments}"
  Main.main(soot_arguments)
end

class Transformer < BodyTransformer
  def initialize
    super
  end
 
  def internalTransform(method_body, phaseName, options)
    method_name = method_body.getMethod().getName()
    $logger.instance.log("Betrete internalTransform(), Methode = #{method_name}")
    if $method_names.empty? || $method_names.include?(method_name)
      puts "Jimple-Code von Methode #{method_name}:\n#{method_body.toString}"
      control_flow_graph = ExceptionalUnitGraph.new(method_body)
      SootHelper.add_IDs_to_cfg_units(control_flow_graph)
      analyser = AcyclicHeapAnalysis.new(control_flow_graph) # Im Konstruktor wird die Analyse durchgeführt
      puts "internalTransform() von #{method_name} fertig. Ergebnis:\n"
      print_result(control_flow_graph, analyser)
      puts ""
    else
      $logger.instance.log("Ueberspringen.")
      puts "Methode ueberspringen: #{method_name}"
    end
    $logger.instance.log("Verlasse internalTransform(), Methode = #{method_name}")
  end
 
  def print_result(control_flow_graph, analyser)
    cfg_it = control_flow_graph.iterator
    while cfg_it.hasNext
      current_unit = cfg_it.next
      puts "\nin: #{analyser.getFlowBefore(current_unit).map { |sexpr_array| SExpression.to_string(sexpr_array) }.join(", ")}"
      puts current_unit.toString # REVIEW: kA wieso das nicht crasht, laut Doku muss man der Methode noch einen Parameter übergeben
      puts "out: #{analyser.getFlowAfter(current_unit).map { |sexpr_array| SExpression.to_string(sexpr_array) }.join(", ")}"
    end
  end
end

