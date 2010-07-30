class Test
  
  def blah
    @b
  end
  
  def blah=(b)
    @b=b
  end
  
end

t = Test.new
t.blah = ("cvbcbv")
puts t.blah
