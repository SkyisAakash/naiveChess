class Map

  def initialize
    @map = []
  end

  def assign(key,value)
    done = false
    @map.each_with_index do |entry, idx|
      if entry[0] == key
        @map[idx][1] = value
        done = true
      end
    end
    @map << [key,value] if done == false
  end

  def lookup(key)
    @map.each do |entry|
      return entry[1] if key == entry[0]
    end
    nil
  end

  def remove(key)
    @map.each_with_index do |entry, idx|
      @map.delete_at(idx) if entry[0] == key
    end
  end

  def show
    @map
  end

end
