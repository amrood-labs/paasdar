# def abc(*arg)
#   puts arg.each { |e| puts e }
# end

# a = :abc

# puts "#{a} xyz"

module Ghi
  def pw
    puts "who"
  end
end

module Abc
  class Xyz
    def pt
      puts "this"
    end
  end
end

module Abc
  class Xyz
    include Ghi
  end
end

a = Abc::Xyz.new
a.pt
a.pw
