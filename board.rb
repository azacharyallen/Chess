#!/usr/bin/env ruby
# encoding: utf-8

require 'colorize'
require_relative './pieces.rb'

class Board

  attr_accessor :board

  def initialize
    @board = Array.new(8) { Array.new(8) }
    self.setup_board
  end

  def setup_board
    [0, 7].each do |row|
      color = (row == 0) ? :black : :white
      [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook].each_with_index do |klass, col|
        @board[row][col] = klass.new([row, col], color, self)
      end
    end

    [1, 6].each do |row|
      color = (row == 1) ? :black : :white
      8.times do |col|
        @board[row][col] = Pawn.new([row, col], color, self)
      end
    end
  end #setup_board

  def display_board
    system "clear"

    (0..7).each do |row|
      print " #{8 - row}"
      (0..7).each do |col|
       if square_empty?([row, col])
         if ((row.even? && col.even?) || (row.odd? && col.odd?))
           print "\033[48;5;94m  \033[m"
         else
           print "\033[48;5;136m  \033[m"
         end
      else
        piece = piece_at_square([row, col])
        if piece.color == :white
          if ((row.even? && col.even?) || (row.odd? && col.odd?))
            print "\033[38;5;255;48;5;94m#{piece.symbol } \033[m"
          else
            print "\033[38;5;255;48;5;136m#{piece.symbol } \033[m"
          end
        else
          if ((row.even? && col.even?) || (row.odd? && col.odd?))
            print "\033[38;5;0;48;5;94m#{piece.symbol } \033[m"
          else
            print "\033[38;5;0;48;5;136m#{piece.symbol } \033[m"
          end
        end
      end
    end
      puts ""
    end
    puts "  a b c d e f g h"
  end #display_board


  def square_empty?(position)
    row, col = position
    @board[row][col].nil?
  end

  def color_at_square(position)
    row, col = position
    @board[row][col].color
  end

  def piece_at_square(position)
    row, col = position
    @board[row][col]
  end

  def set_square(position, piece)
    row, col = position
    @board[row][col] = piece
  end

  def []=(position, piece)
    row, col = position
    @board[row][col] = piece
  end

  def [](position)
    row, col = position
    @board[row][col]
  end

  def move(source, destination, player)
    moving_piece = piece_at_square(source)

    raise "No piece to move at that square" if moving_piece.nil?
    raise "Can't move other player's piece" if moving_piece.color != player
    raise "Piece can not move there" if !moving_piece.moves.include?(destination)
    raise "Can't place yourself in check" if moving_piece.move_into_check?(destination)

    move!(source, destination, player)
  end #move

  def move!(source, destination, player)
    moving_piece = piece_at_square(source)
    #set_square(destination, moving_piece)
    self[destination] = moving_piece
    moving_piece.update_position(destination)
    set_square(source, nil)
  end #move

  def castle(player, direction)
    king = get_player_pieces(player).select { |piece| piece.is_a?(King)}.first
    raise "King has already moved, can't castle" if !king.first_move?

    if direction == :left
      if player == :white
        rook = self[[7, 0]]
        raise "Rook has already move, can't castle" if !rook.first_move?
        raise "Pieces in the way, can't castle" if [[7, 1], [7, 2], [7, 3]].any? { |square| !square_empty?(square)}
        self.move!([7, 4], [7, 2], :white)
        self.move!([7, 0], [7, 3], :white)
      else
        rook = self[[0, 7]]
        raise "Rook has already move, can't castle" if !rook.first_move?
        raise "Pieces in the way, can't castle" if [[0, 5], [0, 6]].any? { |square| !square_empty?(square)}
        self.move!([0, 4], [0, 6], :black)
        self.move!([0, 7], [0, 5], :black)
      end
    else #right
      if player == :white
        rook = self[[7, 7]]
        raise "Rook has already move, can't castle" if !rook.first_move?
        raise "Pieces in the way, can't castle" if [[7, 5], [7, 6]].any? { |square| !square_empty?(square)}
        self.move!([7, 4], [7, 6], :white)
        self.move!([7, 7], [7, 5], :white)
      else
        rook = self[[0, 0]]
        raise "Rook has already move, can't castle" if !rook.first_move?
        raise "Pieces in the way, can't castle" if [[0, 1], [0, 2], [0, 3]].any? { |square| !square_empty?(square)}
        self.move!([0, 4], [0, 2], :black)
        self.move!([0, 0], [0, 3], :black)
      end
    end
  end #castle

  def in_check?(player)
    opposing_player = (player == :white) ? :black : :white

    opposing_pieces = get_player_pieces(opposing_player)
    our_king = get_player_pieces(player).select { |piece| piece.is_a?(King)}.first

    threatened_squares = []

    opposing_pieces.each do |piece|
      threatened_squares += piece.moves
    end

    threatened_squares.include?(our_king.position)
  end #in_check?

  def checkmate?(player)
    !get_player_pieces(player).any? do |piece|
      piece.moves.any? { |move| !piece.move_into_check?(move)}
    end
  end #checkmate?

  def get_player_pieces(player)
    pieces = []

    @board.each do |row|
      row.each do |piece|
        pieces << piece if (!piece.nil? && piece.color == player)
      end
    end

    pieces
  end #get_player_pieces


  def dup
    duped_board = Board.new

   self.board.each_with_index do |row, row_index|
     row.each_with_index do |piece, col_index|
       if !piece.nil?
         duped_piece = piece.dup

         duped_piece.position = piece.position.dup
         duped_piece.board = duped_board
         duped_board.board[row_index][col_index] = duped_piece
       else
         duped_board.board[row_index][col_index] = nil
       end
     end
   end
   duped_board
  end #dup
end #Board



if __FILE__ == $PROGRAM_NAME

  board = Board.new

  duped_board = board.dup

  p board.board[0][0].position.object_id
  p duped_board.board[0][0].position.object_id

end