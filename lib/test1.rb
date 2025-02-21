require "rubygems"
require "bundler/setup"

require "pry"
require "pp"
require "unific"
require "set"

#Benutzte Symbole sind:  :nocycle, :noshare, :noway

#Regeln:
varx = Unific::Var.new("x")
vary = Unific::Var.new("y")
varz = Unific::Var.new("z")
varn = Unific::Var.new("n")
$rules = {
	[:nocycle] => Set.new([ [:noway, [[:get, varx, varn], varx]] ]),
	[:noshare, [varx, vary]] => Set.new([ [:noway, [varx, vary]], [:noway, [vary, varx]], ]),
	[:noway, [varx, vary]] => Set.new([ [:noway, [[:get, varx, varn], vary]] ]),
	[:noway, [varx, [:get, vary, varn]]] => Set.new([ [:noway, [varx, vary] ] ])
}

#term1 < term2 => return true
def order(term1, term2)
	return false if term1==term2
	return false if term2.first == :nocycle or term2.first == :noshare #noshare und nocycle können nie erreicht werden
	return true if term1.first == :nocycle or term1.first == :noshare #von noshare und nocycle kann nur einmal abgeleitet werden
	
	#Einziger übriger erlaubter Fall: links und rechts stehen noways.
	#Format: x.n^i -> y.n^j => a.n^k -> b.n^l
	t1l, t1r = count_gets_left_and_right(term1)
	t2l, t2r = count_gets_left_and_right(term2)
	return t2l >= t1l && t2r <= t1r
end

def count_gets_left_and_right(term)
	fn, (l,r) = *term
	assert{l&&r}
	return count_gets(l), count_gets(r)
end

def count_gets(term)
	return fold_postorder_over_sexp(term) {|element, array| acc_gets(element, array)}
end

#S-Expression sexp in postorder traversen und Funktion f daraufwerfen
def fold_postorder_over_sexp(sexp, &f)
	if sexp.is_a? Array
		rest_arr = sexp[1..-1].map { |kind| fold_postorder_over_sexp(kind, &f)}
		return f.call(sexp.first, rest_arr)
	else
		return f.call(sexp, [])
	end
end

def acc_gets(element, rest)
	sumrest = rest.inject(0, &:+)
	value_element = (if element == :get then 1 else 0 end)
	return value_element + sumrest
end

class Unific::Env
	def shallow_rename_variables term
		_traverse(term) do |v|
			raise "BOOM" unless @theta.include? v
			@theta[v]
		end
	end
end

class TheoremProver
	def initialize rules, order
		@rules = rules
		@order = order
		@canonic_variables = {}
	end
	
	def canonic_variable index
		@canonic_variables[index] ||= Unific::Var.new("canon#{index}")
		return @canonic_variables[index]
	end
	
	#Doku: n wird zu beliebiger Variable.
	def find_rule_applications(term)
		res = Set.new
		@rules.each_pair do |key, value|
			e = Unific::unify(key, term)
			if e
				value.each do |zielterm|
					res<<normalize(e.instantiate(zielterm))
				end
			end
		end
		return res
	end
	
	#ersetze Variablen im Term durch kanonische Variablen 0,1,2... in auftauchender Reihenfolge
	def normalize(term) 
		var = Unific::Env.new.variables(term)
		map = {}
		var.each_with_index do |v, index|
			map[v] = canonic_variable(index)
		end
		e = Unific::Env.new(map)
		return e.shallow_rename_variables(term)
	end

	#Achtung: für solve([:nocycle], [:nocycle]) liefert diese Methode false, und das ist offensichtlich, wenn man sich den Code ansieht. Aber ich bin mir nicht mehr sicher, ob es Absicht war!!!
	#verschmelze die beiden Methoden solve_inefficient() und build_complete_derivation_tree(), um sinnvollere Methode zu bekommen
	def solve(terms, goal)
		derivationtree = [terms]
		while !derivationtree.last.empty?
			nextlevel = Set.new
			derivationtree.last.each { |einterm| nextlevel += find_rule_applications(einterm)}
			nextlevel.each { |term|	return true if Unific::unify(term, goal)}
			nextlevel.delete_if {|element| !(@order.call(element, goal))} 
			derivationtree << nextlevel
		end	
		return false
	end

	#Diese Methode sollte eigentlich nicht benötigt werden. Für Anschauungs- und Debugzwecke füge ich sie trotzdem mal hinzu.
	#Da kein Ziel übergeben wird, werden auch keine Elemente abgeschnitten. Die Anzahl der Ebenen wird durch num_levels begrenzt
	def build_derivation_tree(terms, num_levels, stop_if_empty = true)
		derivationtree = [terms]
		(1..num_levels).each do |level|
			nextlevel = Set.new
			derivationtree.last.each { |einterm| nextlevel += find_rule_applications(einterm)}
			return derivationtree if stop_if_empty && nextlevel.empty?
			derivationtree << nextlevel
		end
		return derivationtree
	end
end
