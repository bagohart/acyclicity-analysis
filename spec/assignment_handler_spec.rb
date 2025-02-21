require "spec_helper"
require_relative "../lib/assignment_handler.rb"
require "wrong/adapters/rspec"

describe AssignmentHandler do
  describe "#assign_new" do
    it "deletes all formulas whose elements are assigned new values with the new constructor, without introducing false" do
      a = AssignmentHandler.new
      input = [
        f0 = Formula.new(:nocycle),
        f1 = Formula.from_strings(:noway, "x", "y"),
        f2 = Formula.from_strings(:noway, "x.n.n", "y"),
        f3 = Formula.from_strings(:noway, "y", "x.m")
      ]
      left_op = Term.from_string("x")
      d, g = a.assign_new(input, left_op)
      expect(g).to be_empty
      expect(d).to contain_exactly(f1, f2, f3)

      left_op = Term.from_string("x.n")
      d, g = a.assign_new(input, left_op)
      expect(g).to be_empty
      expect(d).to contain_exactly(f2)
    end

    it "deletes all formulas whose elements are assigned new values with the new constructor, introducing false" do
      a = AssignmentHandler.new
      input = [
        f0 = Formula.new(:nocycle),
        f1 = Formula.from_strings(:noway, "x", "x.n"),
        f2 = Formula.from_strings(:noway, "x.n.n", "y"),
        f3 = Formula.from_strings(:noshare, "y.n", "y"),
      ]
      left_op = Term.from_string("x")
      d, g = a.assign_new(input, left_op)
      expect(g).to eq [Formula.new(:false)]
      expect(d).to be input

      left_op = Term.from_string("y")
      d, g = a.assign_new(input, left_op)
      expect(g).to eq [Formula.new(:false)]
      expect(d).to be input
    end
  end

  describe "#assign_var" do
    it "executes the replacement rule for assignments of form temp = var" do
      a = AssignmentHandler.new
      input = [
        f0 = Formula.new(:nocycle),
        f1 = Formula.from_strings(:noway, "x", "y"),
        f2 = Formula.from_strings(:noway, "x.n.n", "y"),
        f3 = Formula.from_strings(:noway, "y", "x.m"),
        f4 = Formula.from_strings(:noway, "y.l", "y.m")
      ]
      left_op = Term.from_string("x")
      right_op = Term.from_string("y")
      d, g = a.assign_var(input, left_op, right_op)
      expect(g).to eq(
        [
          Formula.from_strings(:noway, "y", "y"),
          Formula.from_strings(:noway, "y.n.n", "y"),
          Formula.from_strings(:noway, "y", "y.m")
        ]
      )
      expect(d).to contain_exactly(f1, f2, f3)
    end
  end

  describe "#noway_field_assign_replacement" do
    it "takes a suitable formula and generates new formulas for the case (a !-> b) a.n = x (x !-> b)" do
      a = AssignmentHandler.new
      f = Formula.from_strings(:noway, "a", "b")
      other_fields = [Field.new(:m), Field.new(:l), Field.new(:o)]
      new_formulas = a.noway_field_assign_replacement(f, Term.from_string("x"), other_fields)

      expect(new_formulas).to eq(
        [
          Formula.from_strings(:noway, "a.m", "b"),
          Formula.from_strings(:noway, "a.l", "b"),
          Formula.from_strings(:noway, "a.o", "b"),
          Formula.from_strings(:noway, "x", "b"),
          Formula.from_strings(:unequal, "a", "b")
        ]
      )
    end

    it "takes a suitable formula and generates new formulas for the case (a !-> b) a.n = x (x !-> b)" do
      a = AssignmentHandler.new
      f = Formula.from_strings(:noway, "a", "b")
      other_fields = []
      new_formulas = a.noway_field_assign_replacement(f, Term.from_string("x.k"), other_fields)

      expect(new_formulas).to eq(
        [
          Formula.from_strings(:noway, "x.k", "b"),
          Formula.from_strings(:unequal, "a", "b")
        ]
      )
    end
  end

  describe "#assign_field_noway" do
    it "applies the rule from noway_field_assign_replacement to an array of both suitable and unsuitable formulas" do
      a = AssignmentHandler.new
      input = [Formula.new(:nocycle)]
      left_op = Term.from_string("a.n")
      right_op = Term.from_string("x")
      other_fields = [Field.new(:m), Field.new(:l)]
      d, g = a.assign_field_noway(input, left_op, right_op, other_fields)
      expect(d).to eq([])
      expect(g).to eq([])
    end
  end

  describe "#assign_field_noway" do
    it "applies the rule from noway_field_assign_replacement to an array of both suitable and unsuitable formulas" do
      a = AssignmentHandler.new
      input = [
        f0 = Formula.new(:nocycle),
        f1 = Formula.from_strings(:noway, "a", "b"),
        f2 = Formula.from_strings(:noway, "a", "c"),
        f3 = Formula.from_strings(:noway, "a.n", "c"), # nothing happens to this. This is processed in assign_var instead.
        f4 = Formula.from_strings(:noway, "a.m", "c") # nothing happens to this because m is the wrong field
      ]
      left_op = Term.from_string("a.n")
      right_op = Term.from_string("x")
      other_fields = [Field.new(:m), Field.new(:l)]
      d, g = a.assign_field_noway(input, left_op, right_op, other_fields)

      expect(d).to contain_exactly(f1, f2)
      expect(g).to eq(
        [
          Formula.from_strings(:noway, "a.m", "b"),
          Formula.from_strings(:noway, "a.l", "b"),
          Formula.from_strings(:noway, "x", "b"),
          Formula.from_strings(:unequal, "a", "b"),

          Formula.from_strings(:noway, "a.m", "c"),
          Formula.from_strings(:noway, "a.l", "c"),
          Formula.from_strings(:noway, "x", "c"),
          Formula.from_strings(:unequal, "a", "c")
        ]
      )
    end
  end

  describe "#noshare_field_assign_replacement" do
    it "takes a suitable formula and generates new formulas for the case (a !-><- b) a.n = x (x !-><- b, b !-> a )" do
      a = AssignmentHandler.new
      f = Formula.from_strings(:noshare, "a", "b")
      other_fields = [Field.new(:m), Field.new(:l), Field.new(:o)]
      new_formulas = a.noshare_field_assign_replacement(f, Term.from_string("a.n"), Term.from_string("x"), other_fields)

      expect(new_formulas).to eq(
        [
          Formula.from_strings(:noshare, "a.m", "b"),
          Formula.from_strings(:noshare, "a.l", "b"),
          Formula.from_strings(:noshare, "a.o", "b"),
          Formula.from_strings(:noshare, "x", "b"),
          Formula.from_strings(:noway, "b", "a")
        ]
      )
    end

    it "takes a suitable formula and generates new formulas for the case (a !-><- b) a.n = x (x !-><- b, b !-> a )" do
      a = AssignmentHandler.new
      f = Formula.from_strings(:noshare, "a", "b")
      other_fields = []
      new_formulas = a.noshare_field_assign_replacement(f, Term.from_string("a.n"), Term.from_string("x"), other_fields)

      expect(new_formulas).to eq(
        [
          Formula.from_strings(:noshare, "x", "b"),
          Formula.from_strings(:noway, "b", "a")
        ]
      )
    end

    it "Also normalization: the changed part goes to the left side: (a !-><- b) b.n = x (x !-><- a)" do
      a = AssignmentHandler.new
      f = Formula.from_strings(:noshare, "b", "a")
      other_fields = []
      new_formulas = a.noshare_field_assign_replacement(f, Term.from_string("a.n"), Term.from_string("x"), other_fields)

      expect(new_formulas).to eq(
        [
          Formula.from_strings(:noshare, "x", "b"),
          Formula.from_strings(:noway, "b", "a")
        ]
      )
    end
  end

  describe "#assign_field_noshare" do
    it "applies the rule from noshare_field_assign_replacement to an array of both suitable and unsuitable formulas" do
      a = AssignmentHandler.new
      input = [Formula.new(:nocycle)]
      left_op = Term.from_string("a.n")
      right_op = Term.from_string("x")
      other_fields = [Field.new(:m), Field.new(:l)]
      d, g = a.assign_field_noshare(input, left_op, right_op, other_fields)
      expect(d).to eq([])
      expect(g).to eq([])
    end

    it "applies the rule from noshare_field_assign_replacement to an array of both suitable and unsuitable formulas" do
      a = AssignmentHandler.new
      input = [
        f0 = Formula.new(:nocycle),
        f1 = Formula.from_strings(:noshare, "a", "b"),
        f2 = Formula.from_strings(:noshare, "c", "a"),
        f3 = Formula.from_strings(:noshare, "a.n", "c"), # nothing happens to this. This is processed in assign_var instead.
        f4 = Formula.from_strings(:noshare, "a.m", "c") # nothing happens to this because m is the wrong field
      ]
      left_op = Term.from_string("a.n")
      right_op = Term.from_string("x")
      other_fields = [Field.new(:m), Field.new(:l)]
      d, g = a.assign_field_noshare(input, left_op, right_op, other_fields)

      expect(d).to contain_exactly(f1, f2)
      expect(g).to eq(
        [
          Formula.from_strings(:noshare, "a.m", "b"),
          Formula.from_strings(:noshare, "a.l", "b"),
          Formula.from_strings(:noshare, "x", "b"),
          Formula.from_strings(:noway, "b", "a"),

          Formula.from_strings(:noshare, "a.m", "c"),
          Formula.from_strings(:noshare, "a.l", "c"),
          Formula.from_strings(:noshare, "x", "c"),
          Formula.from_strings(:noway, "c", "a")
        ]
      )
    end
  end

  describe "#derive_new_noway_statement" do
    it "is the only way to actually create formulas other than [:nocycle] from entry_initial_flow()" do
      left_op = Term.from_string("a.n")
      right_op = Term.from_string("x")
      a = AssignmentHandler.new
      f = a.derive_new_noway_statement(left_op, right_op)

      expect(f).to eq(Formula.from_strings(:noway, "x", "a"))
    end
  end

  describe "#assign_field" do
    it "takes an array of formulas and applies rules for statements a.n = x, also adds new formula." do
      a = AssignmentHandler.new
      input = [
        f0 = Formula.new(:nocycle),
      ]
      left_op = Term.from_string("a.n")
      right_op = Term.from_string("x")
      other_fields = [Field.new(:m), Field.new(:l)]
      d, g = a.assign_field(input, left_op, right_op, other_fields)

      expect(d).to eq([])
      expect(g).to eq(
        [
          Formula.from_strings(:noway, "x", "a")
        ]
      )
    end

    it "takes an array of formulas and applies rules for statements a.n = x" do
      a = AssignmentHandler.new
      input = [
        f0 = Formula.new(:nocycle),
        f1 = Formula.from_strings(:noshare, "a", "b"),
        f2 = Formula.from_strings(:noway, "a", "c"),
        f3 = Formula.from_strings(:noshare, "a.n.n", "d"),
        f4 = Formula.from_strings(:noshare, "a.m", "c") # nothing happens to this because m is the wrong field
      ]
      left_op = Term.from_string("a.n")
      right_op = Term.from_string("x")
      other_fields = [Field.new(:m), Field.new(:l)]
      d, g = a.assign_field(input, left_op, right_op, other_fields)

      expect(d).to contain_exactly(f1, f2, f3)
      expect(g).to eq(
        [
          Formula.from_strings(:noshare, "x.n", "d"), # f3

          Formula.from_strings(:noway, "a.m", "c"), # f2
          Formula.from_strings(:noway, "a.l", "c"),
          Formula.from_strings(:noway, "x", "c"),
          Formula.from_strings(:unequal, "a", "c"),

          Formula.from_strings(:noshare, "a.m", "b"), # f1
          Formula.from_strings(:noshare, "a.l", "b"),
          Formula.from_strings(:noshare, "x", "b"),
          Formula.from_strings(:noway, "b", "a"),

          Formula.from_strings(:noway, "x", "a") # created independent of replacement rules
        ]
      )
    end
  end
end

