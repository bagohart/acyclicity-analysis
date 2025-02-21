require "spec_helper"
require_relative "../lib/test1.rb"
require "wrong/adapters/rspec"

describe TheoremProver do
describe "#canonic_variable" do
it "returns a canonic variable with the name 'canonNNN'" do
	tp = TheoremProver.new([], nil)
	var = tp.canonic_variable(133)
raise "failure" unless var.name == "canon133"
end
end

describe "#normalize" do
it "replaces variables with canonical variables" do
	varx = Unific::Var.new("x")
	vary = Unific::Var.new("y")
	varz = Unific::Var.new("z")
	theorder =  lambda{|t1,t2|order(t1,t2)}
	tp = TheoremProver.new([], theorder)
	t = tp.normalize( [:nocycle] )
	t = tp.normalize( [:noway, [vary, [:get, vary, varz]]] )
	assert{t==[:noway, [tp.canonic_variable(0), [:get, tp.canonic_variable(0), tp.canonic_variable(1)]]]}
end
end

describe "#find_rule_applications" do
it "finds matching rules and applies them" do
	theorder = lambda{|t1,t2|order(t1,t2)}
	tp = TheoremProver.new($rules, theorder)

	term = [:noshare, [:a, :b]]
	apps = tp.find_rule_applications(term)
	num = apps.size
	assert{num==2}
end
end

describe "#solve" do
it "derivation from :nocycle, possible" do
	theorder = lambda{|t1,t2|order(t1,t2)}
	tp = TheoremProver.new($rules, theorder)

	terme = Set.new
	terme << [:nocycle]
	ziel = [:noway, [[:get, :a, :n], :a]]
	result = tp.solve(terme, ziel)
	assert{result}

	terme = Set.new
	terme << [:nocycle]
	ziel = [:noway, [[:get, [:get, :a, :n], :n], [:get, :a, :n]]]
	result = tp.solve(terme, ziel)
	assert{result}

	terme = Set.new
	terme << [:nocycle]
	ziel = [:noway, [[:get, [:get, :a, :n], :n], :a,]]
	result = tp.solve(terme, ziel)
	assert{result}
end

it "derivation from :nocycle, not possible" do
	theorder = lambda{|t1,t2|order(t1,t2)}
	tp = TheoremProver.new($rules, theorder)

	terme = Set.new
	terme << [:nocycle]
	ziel = [:noshare, [[:get, :a, :n], :b]]
	result = !tp.solve(terme, ziel)
	assert{result}

	terme = Set.new
	terme << [:nocycle]
	ziel = [:noway, [:a, :a]]
	result = !tp.solve(terme, ziel)
	assert{result}

	terme = Set.new
	terme << [:nocycle]
	ziel = [:noway, [:a, :b]]
	result = !tp.solve(terme, ziel)
	assert{result}
end

it "deriving :nocycle, not possible" do
	theorder = lambda{|t1,t2|order(t1,t2)}
	tp = TheoremProver.new($rules, theorder)

	terme = Set.new
	terme << [:noway, [:a, :a]]
	ziel = [:nocycle]
	result = !tp.solve(terme, ziel)
	assert{result}

	terme = Set.new
	terme << [:noshare, [[:get, :a, :n], :b]]
	ziel = [:nocycle]
	result = !tp.solve(terme, ziel)
	assert{result}

	terme = Set.new
	terme << [:nocycle]
	ziel = [:nocycle]
	result = !tp.solve(terme, ziel)
	assert{result}
end

it "derivation from :noshare, possible" do
	theorder = lambda{|t1,t2|order(t1,t2)}
	tp = TheoremProver.new($rules, theorder)

	terme = Set.new
	terme << [:noshare, [:a, :b]]
	ziel = [:noway, [:a, :b]]
	result = tp.solve(terme, ziel)
	assert{result}

	terme = Set.new
	terme << [:noshare, [:a, :b]]
	ziel = [:noway, [:b, :a]]
	result = tp.solve(terme, ziel)
	assert{result}

	terme = Set.new
	terme << [:noshare, [:a, :b]]
	ziel = [:noway, [[:get, [:get, [:get, [:get, :a, :n], :n], :n], :n], :b]]
	result = tp.solve(terme, ziel)
	assert{result}

	terme = Set.new
	terme << [:noshare, [:a, [:get, :b, :n]]]
	ziel = [:noway, [[:get, [:get, [:get, [:get, :a, :n], :n], :n], :n], :b]]
	result = tp.solve(terme, ziel)
	assert{result}

	terme = Set.new
	terme << [:noshare, [:a, [:get, [:get, [:get, [:get, :b, :n], :n], :n], :n]]]
	ziel = [:noway, [:a, :b]]
	result = tp.solve(terme, ziel)
	assert{result}

	terme = Set.new
	terme << [:noshare, [[:get, [:get, :a, :n], :n], [:get, [:get, :b, :n], :n]]]
	ziel = [:noway, [[:get, [:get, :a, :n], :n], :b]]
	result = tp.solve(terme, ziel)
	assert{result}

	terme = Set.new
	terme << [:noshare, [[:get, [:get, :a, :n], :n], [:get, [:get, :b, :n], :n]]]
	ziel = [:noway, [[:get, [:get, :b, :n], :n], :a]]
	result = tp.solve(terme, ziel)
	assert{result}
end

it "derivation from :noshare, not possible" do
	theorder = lambda{|t1,t2|order(t1,t2)}
	tp = TheoremProver.new($rules, theorder)

	terme = Set.new
	terme << [:noshare, [[:get, :a, :n], :b]]
	ziel = [:noway, [:a, :b]]
	result = !tp.solve(terme, ziel)
	assert{result}

	terme = Set.new
	terme << [:noshare, [:a, :b]]
	ziel = [:noway, [:a, [:get, :b, :n]]]
	result = !tp.solve(terme, ziel)
	assert{result}

	terme = Set.new
	terme << [:noshare, [[:get, :a, :n], [:get, [:get, [:get, [:get, :b, :n], :n], :n], :n]]]
	ziel = [:noway, [:a, :b]]
	result = !tp.solve(terme, ziel)
	assert{result}
end

it "deriving :noshare, not possible" do
	theorder = lambda{|t1,t2|order(t1,t2)}
	tp = TheoremProver.new($rules, theorder)

	terme = Set.new
	terme << [:noway, [:a, :b]]
	ziel = [:noshare, [[:get, :a, :n], :b]]
	result = !tp.solve(terme, ziel)
	assert{result}

	terme = Set.new
	terme << [:nocycle]
	ziel = [:noshare, [[:get, :a, :n], :b]]
	result = !tp.solve(terme, ziel)
	assert{result}
end

it "derivation from :noway, possible" do
	theorder = lambda{|t1,t2|order(t1,t2)}
	tp = TheoremProver.new($rules, theorder)

	terme = Set.new
	terme << [:noway, [[:get, :a, :n], :b]]
	ziel = [:noway, [[:get, [:get, [:get, [:get, :a, :n], :n], :n], :n], :b]]
	result = tp.solve(terme, ziel)
	assert{result}

	terme = Set.new
	terme << [:noway, [:a, [:get, [:get, [:get, [:get, :b, :n], :n], :n], :n]]]
	ziel = [:noway, [:a, [:get, :b, :n]]]
	result = tp.solve(terme, ziel)
	assert{result}
end

it "derivation from :noway, not possible" do
	theorder = lambda{|t1,t2|order(t1,t2)}
	tp = TheoremProver.new($rules, theorder)

	terme = Set.new
	terme << [:noway, [[:get, :a, :n], :b]]
	ziel = [:noway, [:a, :b]]
	result = !tp.solve(terme, ziel)
	assert{result}

	terme = Set.new
	terme << [:noway, [:a, :b]]
	ziel = [:noway, [:a, [:get, :b, :n]]]
	result = !tp.solve(terme, ziel)
	assert{result}
end
end
end

describe "#fold_postorder_over_sexp" do
it "folds an sexp with a given block" do
	o = lambda{|t1,t2|order(t1,t2)}
	term = [:noway, [:a, [:get, [:get, [:get, [:get, :b, :n], :n], :n], :n]]]
	result = fold_postorder_over_sexp(term) {|x, y| acc_gets(x, y)}
	assert{4 == result}
end
end

#equality
#nocycle, noshare rechts
#nocycle, noshare links
#count erlaubt
#count nicht erlaubt
describe "#order" do
it "checks terms for equality, should return false" do
	term = [:nocycle]
	result = !order(term,term)
	assert{result}

	term = [:noshare, [:a, :b]]
	result = !order(term,term)
	assert{result}

	term = [:noway, [:a, :b]]
	result = !order(term,term)
	assert{result}
end

it "checks :nocycle or :noshare on the right side(no equality), should return false" do
	t1 = [:noway, [:a, :b]]
	t2 = [:nocycle]
	result = !order(t1,t2)
	assert{result}

	t1 = [:noway, [:a, :b]]
	t2 = [:noshare, [:a, :b]]
	result = !order(t1,t2)
	assert{result}
end

it "checks :nocycle or :noshare on the left side(no equality), should return true" do
 	t1 = [:nocycle]
 	t2 = [:noway, [:a, :b]]
 	result = order(t1,t2)
 	assert{result}

 	t1 = [:noshare, [:a, :b]]
 	t2 = [:noway, [:a, :b]]
 	result = order(t1,t2)
 	assert{result}
end

it "checks :noway on both sides in both directions" do
	t1 = [:noway, [:a, :b]]
	t2 = [:noway, [[:get, [:get, :a, :n], :n], :b]]
	result = order(t1,t2) && !order(t2,t1)
	assert{result}

	t1 = [:noway, [:a, [:get, [:get, [:get, [:get, :b, :n], :n], :n], :n]]]
	t2 = [:noway, [ [:get, :a, :n], :b]]
	result = order(t1,t2) && !order(t2,t1)
	assert{result}

	t1 = [:noway, [:a, [:get, :b, :n]]]
	t2 = [:noway, [:a, :b]]
	result = order(t1,t2) && !order(t2,t1)
	assert{result}
end
end

describe "#build_derivation_tree" do
it "computes a derivation tree given terms and a max number of levels" do
	theorder = lambda{|t1,t2|order(t1,t2)}
	tp = TheoremProver.new($rules, theorder)

	terme = Set.new
	#terme << [:nocycle]
	terme << [:noshare, [:a, :b]]
	tree = tp.build_derivation_tree(terme, 5)
	binding.pry
	#puts tree.inspect
end
end
