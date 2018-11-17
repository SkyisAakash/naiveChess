#require_relative 'chess'
class Player1
  attr_accessor :name
  def initialize(name)
    @name = name
  end
WHITES = [nil,:pw,:kw,:kiw,:qw,:bw, :rw]
BLACKS = [nil,:pb,:kb,:kib,:qb,:bb, :rb]
  def move(board)
    #debugger
    puts("#{name.capitalize}: Enter location of the object that you wanna move")
    object = get_arr
    if board[object[0]][object[1]] == :pw && WHITES.include?(board[object[0]-1][object[1]+1]) && WHITES.include?(board[object[0]-1][object[1]-1])
      location = [object[0]-1,object[1]]
    elsif (board[object[0]][object[1]] == :pb) && BLACKS.include?(board[object[0]+1][object[1]+1]) && BLACKS.include?(board[object[0]+1][object[1]-1])
      location = [object[0]+1,object[1]]
    else
      puts("Enter new location:")
      location = get_arr
    end
    [object, location]
  end

  def get_arr
    while true
      ans = process
      #ans = gets.chomp.split(",").map {|x| x.to_i - 1}

      break if (0..7).cover?(ans[0]) && (0..7).cover?(ans[1])
      puts("Enter within range")
    end
    ans
  end

  def process
    input = gets.chomp
    numbers = input.gsub(/[^\d]/,'')
    [numbers[0].to_i - 1, numbers[1].to_i - 1]
  end
end

class ComputerPlayer
  attr_accessor :name
  WHITES = [:pw,:kw,:kiw,:qw,:bw, :rw]
  BLACKS = [:pb,:kb,:kib,:qb,:bb, :rb]
  def initialize
    @name = "AI"
    @turn = 0
  end
ARMY = [:pw,:kw,:kiw,:qw,:bw, :rw]
  def move(board)
    @turn += 1
    army = []
    others = []
    (0..7).each do |x|
      (0..7).each do |y|
        if ARMY.include?(board[x][y])
          army << [x,y]
        else
          others << [x,y]
        end
      end
    end
    @turn
    #debugger
    if @turn == 1

      object = [6, rand(0..7)]
    else
      army
      object = army.shuffle.sample
    end
    y = object[0]
    x = object[1]
      case board[y][x]
      when :pw
          location = find_move_for_pawn(object, board)
      when :kw
          location = find_move_for_knight(object, board)
      when :rw

    when :bw
      #while true
      #check on negative slope downward
      potent, possible = find_for_bishop(object, board)

        location = potent.sample
        location = possible.sample unless location
      #  break if Board.check_for_bishop(object,location)
      #end
    when :qw
      #while true
        v = rand(0..7)
        location = [[object[0],rand(0..7)],[rand(0..7),object[1]],[object[0]+v,object[1]+v]].sample
      #break if Board.check_move(object,location)
    when :kiw
      potent = []
      list = [[object[0], object[1]+rand(0,1)],[object[0], object[1]-rand(0,1)],[object[0]+rand(0,1), object[1] ],[object[0]-rand(0,1), object[1] ]]
      list.each do |trial|
        if BLACKS.include?(board[trial[0]][trial[1]])
          potent << trial
        else
          possible << trial unless WHITES.include?(board[trial[0]][trial[1]])
        end
      end
      location = potent.sample
      location  = possible.sample unless location
    end
  #    break if check_move([object, location])
  #  end
  p  [object, location]
  end

  def find_move_for_pawn(object, board)
    y = object[0]
    x = object[1]
    p board[y-1]
        if BLACKS.include?(board[y - 1][x + 1])
          [y - 1, x + 1]
        elsif BLACKS.include?(board[y - 1][x - 1])
          [y - 1, x - 1]
        else
          [object[0]-1, object[1]]
        end
  end

  def find_move_for_knight(object, board)
    y = object[0]
    x = object[1]
    possible = [[y+1, x+2], [y+2, x+1], [y-2, x-1], [y-1, x-2], [y-1, x+2], [y-2, x+1], [y+2, x-1], [y+1, x-2]]
    potent = possible.select{ |lo| BLACKS.include?(board[lo[0]][lo[1]]) }
    return possible.sample if potent == []
    return potent.sample
  end

  def find_move_for_rook(object, board)
    potent = []
    pointer = []
    y = object[0]
    x = object[1]
    (0...x).each do |xi|
      if BLACKS.include?(board[xi][y])
        p_pointer = [xi,y]
      elsif WHITES.include?(board[xi][y])
        pointer = [xi+1,y]
      end
    end
    possible << pointer
    potent << p_pointer
    (x+1..7).each do |xi|
      p_pointer = [xi,y] if BLACKS.include?(board[xi][y])
      pointer = [xi-1,y] if WHITES.include?(board[xi][y])
    end
    potent << pointer
    p_potent << p_pointer
    (0...y).each do |yi|
      p_pointer = [x,yi] if BLACKS.include?(board[x][yi])
      pointer = [x,yi+1] if WHITES.include?(board[x][yi])
    end
    potent << pointer
    p_potent << p_pointer
    (x+1..7).each do |yi|
      p_pointer = [x,yi] if BLACKS.include?(board[x][yi])
      pointer = [x,yi-1] if WHITES.include?(board[x][yi])
    end
    potent << pointer
    p_potent << p_pointer
    location = p_potent.sample
    location = potent.sample unless location
    #  break if Board.check_for_rook(object,location)
  #end

  end
  def find_for_bishop(object, board)
    potent = []
    possible = []
    x = object[1]
    y = object[0]
    (0..7).each do |c|
      break if x+c > 7 || y+c > 7
      if BLACKS.include?(board[x+c][y+c])
        potent << [x+c,y+c]
        break
      elsif WHITES.include?(board[x+c][y+c])
        possible << [x+c-1,y+c-1]
        break
      else
        possible << [x+c,y+c]
      end
    end
    #check on negative slope upward left
    (0..7).each do |c|
      break if x-c < 0 || y-c < 7
      if BLACKS.include?(board[x+c][y+c])
        potent << [x-c,y-c]
        break
      elsif WHITES.include?(board[x+c][y+c])
        possible << [x-c+1,y-c+1]
        break
      else
        possible << [x-c,y-c]
      end
    end
  #check on positive slope upward right
    (0..7).each do |c|
      break if x-c < 0 || y+c > 7
      if BLACKS.include?(board[x-c][y+c])
        potent << [x-c,y+c]
        break
      elsif WHITES.include?(board[x+c][y+c])
        possible << [x-c-1,y+c-1]
        break
      else
        possible << [x-c,y+c]
      end
    end
#check on positive slope downward left
    (0..7).each do |c|
      break if x+c > 7 || y-c < 0
      if BLACKS.include?(board[x+c][y-c])
        potent << [x+c,y-c]
        break
      elsif WHITES.include?(board[x+c][y-c])
        possible << [x+c-1,y-c+1]
        break
      else
        possible << [x+c,y-c]
      end
    end
    return potent, possible
  end

end
