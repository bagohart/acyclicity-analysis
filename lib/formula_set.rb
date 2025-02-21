require "java"
require_relative "soot-trunk.jar"
java_import Java::Soot.toolkits.scalar.ArraySparseSet

class FormulaSet < ArraySparseSet
  def initialize(*ruby_array)
    super()
    ruby_array.first.each { |formula| add(formula) } unless ruby_array.empty?
  end

  def to_ruby_array
    to_a # Thanks to JRuby magic, this somehow does the right thing.
  end

  def copy_from_ruby_array(ruby_array)
    clear
    ruby_array.each { |formula| add(formula) }
  end

  def to_s
    "{ #{self.to_a.join(", ")} }"
  end
end

