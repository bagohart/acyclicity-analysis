require "spec_helper"
require_relative "../lib/acyclic_heap_analysis.rb"
require_relative "../lib/soot_wrapper.rb"
require_relative "../lib/main_helper.rb"
require "wrong/adapters/rspec"

describe AcyclicHeapAnalysis do
  before(:all) do
    args = [
             #"-d",
             #"-sv",
             "-scp",
             #".:/usr/lib/jvm/default-java/jre/lib/rt.jar:./javax-crypto.jar:./required_jar/:./java_examples/wrapped_list/",
             ".:/usr/lib/jvm/default-java/jre/lib/rt.jar:./javax-crypto.jar:./required_jar/:./java_examples/test/",
             "-c",
             #"WrappedList",
             "Test",
#             "-f",
#             "top",
#             "-f",
#             "l",
#             "-f",
#             "r",
             "-f",
             "m",
             "-f",
             "n",
             "-f",
             "o",
           ]
    process_cmdline_input(args)
    setup_soot($soot_class_path)
    soot_class = load_soot_class_and_support_classes($class_name)
    sm = soot_class.getMethods.select { |sm| sm.getName == "testMethod" }.first
    mb = sm.retrieveActiveBody
    PackManager.v.getTransform("jb.ne").apply(mb)
#    PackManager.v.getTransform("jb.a").apply(mb) #scheint nix zu aendern
#    PackManager.v.getTransform("jb.ulp").apply(mb)
#    PackManager.v.getTransform("jb.lp").apply(mb)
    @ug = ExceptionalUnitGraph.new(mb)
    @analysis = AcyclicHeapAnalysis.new(@ug, $relevant_fields, Initialiser.new, AssignmentHandler.new, InvariantHandler.new)

    @no_assign_stmt = @ug.iterator.select { |unit| unit.getTag("unit_ID").getValue.include?("0:") }.first
    @field_assign_stmt = @ug.iterator.select { |unit| unit.getTag("unit_ID").getValue.include?("16:") }.first
    @simple_assign_stmt = @ug.iterator.select { |unit| unit.getTag("unit_ID").getValue.include?("4:") }.first
    @new_assign = @ug.iterator.select { |unit| unit.getTag("unit_ID").getValue.include?("5:") }.first
    @null_assign = @ug.iterator.select { |unit| unit.getTag("unit_ID").getValue.include?("10:") }.first
  end

  describe "#entryInitialFlow" do
    it "returns the initial flow for the entry position of the control flow graph, in this case the last node" do
      result = @analysis.entryInitialFlow

      expect(result).to be_instance_of(FormulaSet)
      expect(result.to_a[0]).to eq(Formula.new(:nocycle))
    end
  end

  describe "#newInitialFlow" do
    it "returns the initial flow for all not-entry positions of the control flow graph (not the last node)" do
      result = @analysis.newInitialFlow

      expect(result).to be_instance_of(FormulaSet)
      expect(result.to_a).to eq([])
    end
  end

  describe "#copy" do
    it "deletes contents in dest, then copies contents from source to dest" do
      input = [
        f0 = Formula.new(:nocycle),
        f1 = Formula.from_strings(:noway, "x", "y"),
        f2 = Formula.from_strings(:noway, "x.n.n", "y"),
        f3 = Formula.from_strings(:noway, "y", "x.m"),
        f4 = Formula.from_strings(:noway, "y.l", "y.m")
      ]
      source = FormulaSet.new(input)
      dest = FormulaSet.new
      @analysis.copy(source, dest)

      expect(dest.to_a).to eq(input)
    end
  end

  describe "#flow_through_assign" do
    it "takes a relevant assign statement a = null and input, returns output as ruby array, example simple replace to null" do
      i2 = Formula.new(:noway, Term.new(LocalVar.new(@null_assign.getLeftOp)), Term.from_string("y")) 
      input = [Formula.new(:nocycle), i2]
      output = @analysis.flow_through_assign(input, @null_assign)
      f2 = output.to_a[1]
      expect(f2.to_s).to eq("[:NOWAY(null, y)]")
    end

    it "takes a relevant assign statement a = null and input, returns output as ruby array, example simple replace (part) to null" do
      i2 = Formula.new(:noway, Term.new(LocalVar.new(@null_assign.getLeftOp), Field.new(:n)), Term.from_string("y")) 
      input = [Formula.new(:nocycle), i2]
      output = @analysis.flow_through_assign(input, @null_assign)
      f2 = output.to_a[1]

      expect(f2.to_s).to eq("[:NOWAY(null.n, y)]")
    end

    it "takes a relevant assign statement a.n = x and input, returns output as ruby array, example creation of new formula" do
      input = [Formula.new(:nocycle)]
      output = @analysis.flow_through_assign(input, @field_assign_stmt)
      f = output.to_a.last

      expect(f.to_s).to eq("[:NOWAY(temp$8, temp$7)]")
    end

    it "takes a relevant assign statement a.n = x and input, returns output as ruby array, example simple replacement" do
      i2 = Formula.new(:noway, Term.new(LocalVar.new(@field_assign_stmt.getLeftOp.getBase), Field.new(@field_assign_stmt.getLeftOp.getField)), Term.from_string("y")) 
      input = [Formula.new(:nocycle), i2]
      output = @analysis.flow_through_assign(input, @field_assign_stmt)
      f2 = output.to_a[1]

      expect(f2.to_s).to eq("[:NOWAY(temp$8, y)]")
    end

    it "takes a relevant assign statement a.n = x and input, returns output as ruby array, example field assign" do
      i2 = Formula.new(:noway, Term.new(LocalVar.new(@field_assign_stmt.getLeftOp.getBase)), Term.from_string("y")) 
      input = [Formula.new(:nocycle), i2]
#$dang = true
      output = @analysis.flow_through_assign(input, @field_assign_stmt)
      o = output.to_a.map { |f| f.to_s }[1..-2]

      expect(o).to eq(["[:NOWAY(temp$7.n, y)]", "[:NOWAY(temp$7.o, y)]", "[:NOWAY(temp$8, y)]", "[:UNEQUAL(temp$7, y)]"])
    end

    it "takes a relevant assign statement a = null and input noshare, returns output as ruby array, example simple replace to null" do
      i2 = Formula.new(:noshare, Term.new(LocalVar.new(@null_assign.getLeftOp)), Term.from_string("y")) 
      input = [Formula.new(:nocycle), i2]
      output = @analysis.flow_through_assign(input, @null_assign)
      f2 = output.to_a[1]
      expect(f2.to_s).to eq("[:NOSHARE(null, y)]")
    end

    it "takes a relevant assign statement a = null and input noshare, returns output as ruby array, example simple replace (part) to null" do
      i2 = Formula.new(:noshare, Term.new(LocalVar.new(@null_assign.getLeftOp), Field.new(:n)), Term.from_string("y")) 
      input = [Formula.new(:nocycle), i2]
      output = @analysis.flow_through_assign(input, @null_assign)
      f2 = output.to_a[1]

      expect(f2.to_s).to eq("[:NOSHARE(null.n, y)]")
    end

    it "takes a relevant assign statement a.n = x and input noshare, returns output as ruby array, example simple replacement" do
      i2 = Formula.new(:noshare, Term.new(LocalVar.new(@field_assign_stmt.getLeftOp.getBase), Field.new(@field_assign_stmt.getLeftOp.getField)), Term.from_string("y")) 
      input = [Formula.new(:nocycle), i2]
      output = @analysis.flow_through_assign(input, @field_assign_stmt)
      f2 = output.to_a[1]

      expect(f2.to_s).to eq("[:NOSHARE(temp$8, y)]")
    end

    it "takes a relevant assign statement a.n = x and input with noshare, returns output as ruby array, example field assign" do
      i2 = Formula.new(:noshare, Term.new(LocalVar.new(@field_assign_stmt.getLeftOp.getBase)), Term.from_string("y")) 
      input = [Formula.new(:nocycle), i2]
      output = @analysis.flow_through_assign(input, @field_assign_stmt)
      o = output.to_a.map { |f| f.to_s }[1..-2]

      expect(o).to eq(["[:NOSHARE(temp$7.n, y)]", "[:NOSHARE(temp$7.o, y)]", "[:NOSHARE(temp$8, y)]", "[:NOWAY(y, temp$7)]"])
    end

    it "takes a relevant assign statement a = x and input, returns output as ruby array, example simple replace to null" do
      i2 = Formula.new(:noway, Term.new(LocalVar.new(@new_assign.getLeftOp)), Term.from_string("y")) 
      input = [Formula.new(:nocycle), i2]
      output = @analysis.flow_through_assign(input, @new_assign)

      expect(output).to eq([Formula.new(:nocycle)])
    end

    it "takes a relevant assign statement a = b and input, returns output as ruby array, example simple replace to null" do
      i2 = Formula.new(:noway, Term.new(LocalVar.new(@simple_assign_stmt.getLeftOp)), Term.from_string("y")) 
      input = [Formula.new(:nocycle), i2]
      output = @analysis.flow_through_assign(input, @simple_assign_stmt)
      f2 = output.to_a[1]

      expect(f2.to_s).to eq("[:NOWAY(this.head, y)]")
    end
  end
end

