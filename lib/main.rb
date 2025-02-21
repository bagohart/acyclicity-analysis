require "rubygems"
require "bundler/setup"

require_relative "soot_wrapper"
require_relative "protocol"
require_relative "main_helper.rb"

list_to_analyse_wl = [
"reverseDeleteAddDeleteNested",
#"reverseDeleteAddNested",
#"rds2",
#"reverseDeleteShift",
#"appendUnmerge",
#"combine5",
#  "bubble",
#   "<init>", "isEmpty", "print", "getFirstNode",
#   "addElementFront",
#   "addElementBack",
#  "addElementAtIndex",
#  "deleteElementFront",
#  "deleteElementBack",
#  "deleteElementAtIndex",
#  "reverse_cf",
#  "append",
#  "skipMiddleElements",
#   "skipMiddleElements_v2",
#  "shift_safe",
#  "shift_safe_v2",
#  "unmerge",
#   "unmerge_weird", # nicht beweisbar.
#  "merge_unsafe", #komische Ergebnisse, aber sollte mit Verbesserung des TP (noshare) ausgebuegelt werden
#   "swap",
#   "appendMiddle",
#   "unmergeAppend", #2. Versuch. tut nicht. # Methode fehlt???
#   "unmergeMerge", #tut nicht.
#  "shift_full_circle", #tut, problemlos.
#    "swap_neighbours",
# "reverseDeleteNested",
# mach das hier mal: 2 angrenzende elemente vertauschen. getan. fehlt: swap neighbours bis zum ende der liste immer wiederholt (durchbubblen).
  ]

list_to_analyse_wbt = [
#  "<init>",
#  "initExample1",
#  "addFrontL",
#  "addBackL",
#  "addElementAtPath",
#  "deleteFrontKeepL",
#  "deleteBackL",
#  "deleteAtPathKeepL",
#  "swap",
#  "swapLeftEdge", #dafuq wo kommen die ganzen sinnlos-variablen her???
#   "appendL",
#   "skipMiddleElements",
#   "rotateSafe",
   "rotateSafeRepeat", # geht nicht, weil ich keine invariante habe fuer t.l^i.l -> t.l^i.r (oder doch?)
#    "rotateSafeToList", #neuer Fehler gefunden :(
#    "rotateSafeToList2",


]

#weitere Ideen:
#sicheres swap #dafuq
#append in der Mitte der Liste #geht
#beweisbares merge & append (diesmal schlauer programmieren) #nicht so leicht aka kA wie

#kombinierte Ideen:
#unmerge und wieder merge #nein, einfach nein.
#unmerge, letztes und erstes element löschen, wieder merge #wird auch nicht tun...
#unmerge, append (eine vorne, eine hinten), wieder merge #nein.

#Dinge am Ende einer Liste löschen, und ans Ende der anderen Liste anhängen, bis die eine Liste leer ist.

#shift_safe im kreis bis zur originalliste (oder eins davor) iterieren

def main
end

args = [
       "-d",
#       "-sv",
       "-scp",
#       ".:/usr/lib/jvm/default-java/jre/lib/rt.jar:./javax-crypto.jar:./required_jar/:../java_examples/wrapped_list/",
       ".:/usr/lib/jvm/default-java/jre/lib/rt.jar:../java_examples/wrapped_list/",
       "-c",
       "WrappedList",
       "-f",
       "next",
#      "-f",
#      "left",
#      "-f",
#      "right",
       ]
process_cmdline_input(args)
Logger.instance.open('protokoll.txt')
analyse($class_name, list_to_analyse_wl)

