#!/usr/bin/env ruby
# encoding: utf-8

class Piece

  attr_reader :symbol, :color
  attr_accessor :board, :position

  def initialize(position, color, board)
    @color = color
    @board = board
    @position = position
  end

  def moves
    raise "Don't know how to do that"
  end

  def update_position(position)
    @position = position
  end

  def move_into_check?(destination_position)
    duped_board = @board.dup

    duped_board.move!(self.position, destination_position, self.color)

    return duped_board.in_check?(self.color)
  end
end #Piece

class SlidingPiece < Piece

  def moves
    valid_positions = []
    offsets = move_directions

    offsets.each do |offset|
      row_offset, col_offset = offset
      current_row, current_col = self.position

      while (current_row + row_offset).between?(0, 7) && (current_col + col_offset).between?(0, 7)
        current_row += row_offset
        current_col += col_offset

        if @board.square_empty?([current_row, current_col])
          valid_positions << [current_row, current_col]
        else
          if @board.color_at_square([current_row, current_col]) != self.color
            valid_positions << [current_row, current_col]
          end
        end

        break if !(@board.square_empty?([current_row, current_col]))
      end #while
    end #each
    valid_positions
  end

end #SlidingPiece

class SteppingPiece < Piece
  def moves
    valid_positions = []

    offsets = move_directions

    offsets.each do |offset|
      row_offset, col_offset = offset
      current_row, current_col = self.position

      current_row += row_offset
      current_col += col_offset

      next if !current_row.between?(0,7) || !current_col.between?(0,7)

      if @board.square_empty?([current_row, current_col])
        valid_positions << [current_row, current_col]
      else
        if @board.color_at_square([current_row, current_col]) != self.color
          valid_positions << [current_row, current_col]
        end
      end

    end #each
    valid_positions
  end

end #SteppingPiece

class King < SteppingPiece

  def initialize(position, color, board)
    super(position, color, board)
    @first_move = true
    @symbol = "♚"
  end #initialize

  def move_directions
    offsets = [1,0,-1].product([1,-1,0])
    offsets.delete([0,0])
    offsets
  end

  def update_position(position)
    @position = position
    @first_move = false
  end

  def first_move?
    @first_move
  end
end #King

class Queen < SlidingPiece

  def initialize(position, color, board)
    super(position, color, board)
    @first_move = true
    @symbol = "♛"
  end

  def move_directions
    offsets = [1,0,-1].product([1,-1,0])
    offsets.delete([0,0])
    offsets
  end
end #Queen

class Bishop < SlidingPiece

  def initialize(position, color, board)
    super(position, color, board)
    @first_move = true
    @symbol = "♝"
  end

  def move_directions
    offsets = [1, -1].product([1, -1])
  end
end #Bishop

class Rook < SlidingPiece

  def initialize(position, color, board)
    super(position, color, board)
    @first_move = true
    @symbol = "♜"
  end

  def move_directions
    offsets = [[1,0],[-1,0],[0,1],[0,-1]]
  end

  def update_position(position)
    @position = position
    @first_move = false
  end

  def first_move?
    @first_move
  end
end #Rook

class Knight < SteppingPiece

  def initialize(position, color, board)
    super(position, color, board)
    @first_move = true
    @symbol = "♞"
  end

  def move_directions
    offsets = [-2,2].product([1,-1])
    offsets += offsets.map(&:reverse)
    offsets
  end
end #Knight

class Pawn < Piece

  attr_reader = :first_move

  def initialize(position, color, board)
    super(position, color, board)
    @first_move = true
    @symbol = "♟"
  end

  def update_position(position)
    @position = position
    @first_move = false
  end

  def moves
    valid_positions = []
    valid_positions += standard_moves
    valid_positions += diagonal_captures
  end #moves

  def standard_moves
    valid_positions = []

    offsets = (self.color == :white) ? [[-1, 0]] : [[1, 0]]

    if @first_move
       (self.color == :white) ? offsets << [-2, 0] : offsets << [2, 0]
    end

    offsets.each do |offset|
      row_offset, col_offset = offset
      current_row, current_col = self.position

      current_row += row_offset
      current_col += col_offset

      break if !@board.square_empty?([current_row, current_col])

      break if !current_row.between?(0,7) || !current_col.between?(0,7)

      valid_positions << [current_row, current_col]
    end #each
    valid_positions
  end #standard_moves

  def diagonal_captures
    valid_positions = []
    offsets = (self.color == :white) ? [[-1, -1], [-1, 1]] : [[1, -1], [1, 1]]

    offsets.each do |offset|
      row_offset, col_offset = offset
      current_row, current_col = self.position

      current_row += row_offset
      current_col += col_offset

      if current_row.between?(0,7) && current_col.between?(0,7)
        if !@board.square_empty?([current_row, current_col])
          if @board.color_at_square([current_row, current_col]) != self.color
            valid_positions << [current_row, current_col]
          end
        end
      end
    end #each
    valid_positions
  end #diagonal_captures
end #Pawn



if __FILE__ == $PROGRAM_NAME

  king = King.new([0, 0], :black, [])
  p king.is_a?(Pawn)

end