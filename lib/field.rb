require "java"

require_relative "soot-trunk.jar"
require_relative "soot_helper.rb"

java_import Java::Soot.SootField

# exists as a Wrapper class around Soot.SootField for two reasons:
# enables calling of to_s without monkey-patching Soot core classes (bad idea, especially with JRuby)
# enables using Symbols instead of Soot objects to facilitate Unit testing
class Field
  attr_accessor :field
  def initialize(field_value)
    assert { field_value.is_a?(Symbol) || field_value.is_a?(SootField) }
    @field = field_value
    freeze
  end

  def ==(other)
    return false unless other.instance_of?(Field)
    @field == other.field # possible because Soot apparently constructs Fields to only exist once
  end
  alias :eql? :==

  def to_s
    case @field
    when Symbol    then @field.to_s
    when SootField then $soot_verbose ? @field.toString : @field.getName
    end
  end
end

