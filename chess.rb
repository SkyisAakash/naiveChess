require 'byebug'
require_relative 'player1'
class Board
  CHESS = { rb: "\u{265C}", kb: "\u{265E}", bb: "\u{265D}", pb: "\u{265F}", kib: "\u{265A}", qb: "\u{265B}", rw: "\u{2656}", kw: "\u{2658}", bw: "\u{2657}", pw:"\u{2659}", kiw: "\u{2654}", qw: "\u{2655}"}
  WHITES = [:rw, :kw, :bw, :pw, :kiw, :qw]
  BLACKS = [:rb, :kb, :bb, :pb, :kib, :qb]
  attr_accessor :board, :player1, :player2, :name1, :name2, :dead_blacks, :dead_whites

  def initialize(player1, player2)
    design = Array.new(8){Array.new(8)}
    design[1] = Array.new(8,:pb)
    design[6] = Array.new(8,:pw)
    design[0][0] = design[0][7] = :rb
    design[7][0] = design[7][7] = :rw
    design[0][1] = design[0][6] = :kb
    design[7][1] = design[7][6] = :kw
    design[0][2] = design[0][5] = :bb
    design[7][2] = design[7][5] = :bw
    design[0][3]  = :qb
    design[0][4]  = :kib
    design[7][3]  = :qw
    design[7][4]  = :kiw
    @board = design.dup
    @player1 = player1
    @player2 = player2
    @name1 = player1.name
    @name2 = player2.name
    @dead_blacks = []
    @dead_whites = []
  end

  def boards(pos)
    board[pos[0]][pos[1]]
  end

  def display
    puts('--------------------------------------------------------')
    puts("#{name1.capitalize} plays as white \u{265A}")
    puts("#{name2.capitalize} plays as black \u{2654}")
    print('  ')
    board.length.times { |i| print("   #{i + 1}  ") }
    print("\n  ")
    board.length.times { print('______') }
    puts("\n")
    i = 1
    board.each do |row|
      box(row, i)
      i += 1
    end
  end

  def box(row,n)
    print('  |')
    row.length.times { print('     |') }
    puts("\n")
    print("#{n} ")
    row.length.times do |i|
      if row[i].nil?
        print('|     ')
      else
        print("|  #{CHESS[row[i]]}  ")
      end
    end
    print('| ')
    if n == 1
      dead_whites.each { |x| print(" #{CHESS[x]} ") }
    elsif n == 8
      dead_blacks.each { |x| print(" #{CHESS[x]} ") }
    end
    print("\n  ")
    row.length.times { print('|_____') }
    puts("|\n")
  end

  def step(move)
    @dead_blacks << boards(move[1]) if BLACKS.include?(boards(move[1]))
    @dead_whites << boards(move[1]) if WHITES.include?(boards(move[1]))
    board[move[1][0]][move[1][1]] = boards(move[0])
    board[move[0][0]][move[0][1]] = nil
  end

  def check_for_knights(move)
    start_x = move[0][0]
    start_y = move[0][1]
    end_x = move[1][0]
    end_y = move[1][1]
    return true if (start_x - end_x).abs == 2 && (start_y - end_y).abs == 1
    return true if (start_y - end_y).abs == 2 && (start_x - end_x).abs == 1
    puts("knights move on path shaped like \"L\" only")
    false
  end

  def check_for_rook(move)
    start_x = move[0][0]
    start_y = move[0][1]
    end_x = move[1][0]
    end_y = move[1][1]
    if start_x == end_x
      start_y, end_y = end_y, start_y if start_y > end_y
      (start_y + 1..end_y - 1).all? do |x|
        board[start_x][x].nil?
      end
    elsif start_y == end_y
      start_x, end_x = end_x, start_x if start_x > end_x
      (start_x + 1..end_x - 1).all? do |x|
        board[x][start_y].nil?
      end
    else
      puts('Rooks move on straight line only') unless [:qb,:qw].include?(boards(move[1]))
      false
    end
  end

  def check_for_bishop(move)
    start_x = move[0][0]
    start_y = move[0][1]
    end_x = move[1][0]
    end_y = move[1][1]

    return false if (start_x - end_x).abs != (start_y - end_y).abs
    if (end_y < start_y && end_x < start_x) || (end_y > start_y && end_x > start_x)
      start_x,start_y,end_x,end_y = end_x,end_y,start_x,start_y if start_x > end_x
      while start_x < end_x - 1
        start_x += 1
        start_y += 1
        return false if !board[start_x][start_y].nil?
      end
    else
      start_x,start_y,end_x,end_y = end_x,end_y,start_x,start_y if start_x > end_x
      while start_x < end_x - 1
        start_x += 1
        start_y -= 1
        return false if !board[start_x][start_y].nil?
      end
    end
    true
  end



  def check_move(move)
    start = move[0]
    en = move[1]
    if start == en
      puts("Please enter valid move, you can't skip a turn")
      return false
    elsif (WHITES.include?(boards(start)) && WHITES.include?(boards(en))) || (BLACKS.include?(boards(start)) && BLACKS.include?(boards(en)))
      puts('You cannot kill your own army')
      return false
    else
      case boards(start)
      when :pb
        if [[start[0] + 1, start[1] + 1], [start[0] + 1, start[1] - 1]].include?(en)
          return true if WHITES.include?(boards(en))
        else
          en == [start[0] + 1, start[1]]
        end
      when :pw
        if [[start[0] - 1, start[1] + 1], [start[0] - 1, start[1] - 1]].include?(en)
          return true if BLACKS.include?(boards(en))
        else
          en == [start[0] - 1, start[1]]
        end
      when :kb, :kw
        check_for_knights(move)
      when :rw, :rb
        check_for_rook(move)
      when :kiw, :kib
        (start[0] - en[0]).abs <= 1 && (start[1] - en[1]).abs <= 1
      when :bb, :bw
        check_for_bishop(move)
      when :qw, :qb
        ans = check_for_bishop(move) || check_for_rook(move)
        ans
      end
    end

  end

  def move(player)
    while true
      moves = player.move(board)
      if (player.name == name2 && WHITES.include?(boards(moves[0]))) || (player.name == name1 && BLACKS.include?(boards(moves[0])))
        break if check_move(moves)
        puts('Unvalid move!')
      else
        puts('Thats not your army! Check coordinates you entered')
      end
    end
    moves
  end

  def play
    while board.flatten.include?(:kiw) && board.flatten.include?(:kib)
      display
      move1 = move(player1)
      step(move1)
      display
      old = board.dup
      move2 = move(player2)
      step(move2)
    end
    conclude
  end

  def conclude
    display
    if board.flatten.include?(:kiw)
      puts("#{name2} wins!")
    else
      puts("#{name1} wins!")
    end
  end
end

if $PROGRAM_NAME == __FILE__
  puts("Enter 1 for Single or 2 for Multiplayer:")
  players = gets.chomp.to_i
  puts("Enter name of first player:")
  player1 = Player1.new(gets.chomp)
  if players == 1
    player2 = ComputerPlayer.new
  else
    puts("Enter name of second player:")
    player2 = Player1.new(gets.chomp)
  end
  
  game = Board.new(player1,player2)
  game.play
end
