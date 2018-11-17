class Stack
  def initialize
    #create ivar to store stack here
    @ivar = []
  end

  def add(el)
    #adds an element to stack
    @ivar << el
  end

  def remove
    #remove one element from stack
    @ivar.pop
  end

  def show
    #return a copy of stack
    @ivar
  end

end
