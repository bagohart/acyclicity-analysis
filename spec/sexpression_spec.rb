#require "spec_helper"
#require_relative "../lib/sexpression.rb"
#require "wrong/adapters/rspec"
#
#describe SExpression do
#  describe "#get_base" do
#    it "computes base of part of SExpression" do
#      sexpr_part = [:get, :a, :n]
#      base = SExpression.get_base(sexpr_part)
#      assert { base == :a }
#    end
#  end
#end
