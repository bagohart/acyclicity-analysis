require "java"

require_relative "soot-trunk.jar"
require_relative "soot_helper.rb"

java_import Java::Soot.Local

# exists as a Wrapper class around Soot.Local for two reasons:
# enables calling of to_s without monkey-patching Soot core classes (bad idea, especially with JRuby)
# enables using Symbols instead of Soot objects to facilitate Unit testing
class LocalVar
  attr_accessor :var
  def initialize(var)
    assert { var.is_a?(Symbol) || var.is_a?(Local) || var.is_a?(NullConstant)}
    @var = var
    freeze
  end

  def ==(other)
    return false unless other.instance_of?(self.class)
    case @var
    when Symbol then @var == other.var
    when Local  then @var.equivTo(other.var)
    end
  end
  alias :eql? :==

  def to_s
    case @var
    when Symbol then @var.to_s
    when Local  then @var.toString
    when NullConstant  then @var.toString
    end
  end
end

