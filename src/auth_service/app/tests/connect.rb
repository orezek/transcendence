# frozen_string_literal: true

class Test
  def initialize
    @class_var = 'test'
  end

  def print_test()
    puts @class_var
  end
end

test = Test.new
test.print_test()

puts "Ahoj from connect!"

MAGIC_VALUE = 1001