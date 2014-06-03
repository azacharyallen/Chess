#!/usr/bin/env ruby
# encoding: utf-8

require_relative './board.rb'
require 'yaml'

class Chess

  attr_accessor :current_player

  def initialize
    @game_board = Board.new
    @current_player = :white
    self.generate_coordinate_hashes
  end

  def play
    self.greeting

    while (!@game_board.checkmate?(current_player))

      @game_board.display_board

      if @game_board.in_check?(current_player)
        puts "CHECK!"
        system "say check"
      end

      begin
        make_move
      rescue => e
        puts "#{e.message}: Please enter another move..."
        retry
      end

      self.current_player = (current_player == :white) ? :black : :white
    end #while

    @game_board.display_board

    puts "CHECKMATE!"
    system "say checkmate"
  end #play

  def greeting
    system "clear"
    puts "Let's play Chess!".colorize(:white)
    puts ""
    puts "                                                  ".colorize(:background => :red)
    puts "    Moves are entered in the format 'a2 to a4'    ".colorize(:white).colorize(:background => :red)
    puts "    Castle with 'castle to [left || right]'        ".colorize(:white).colorize(:background => :red)
    puts "                                                  ".colorize(:white).colorize(:background => :red)
    puts ""
    puts ""
    puts "Type 'concede' to concede the game"
    puts "Type 'save' to save the game and exit"
    puts "Type 'exit' or 'abort' to quit without saving"
    puts ""
    puts ""
    puts "Press any key to continue...".colorize(:green)
    gets
  end


  def make_move
    puts "#{current_player.to_s.upcase}, please enter your move:"

    move = gets.chomp.split(' to ')

    case move[0]
    when "save"
      save
    when "exit","abort"
      system "clear"
      abort "Game aborted!"
    when "concede"
      abort "#{current_player.upcase} concedes!"
    when "castle"
        @game_board.castle(current_player, move.last.to_sym)
        return
    end


    source, destination = move

    begin
      source = coordinate_conversion(source.split(''))
    rescue => e
      raise "Invalid source square:"
    end

    begin
      destination = coordinate_conversion(destination.split(''))
    rescue => e
      raise "Invalid destination square:"
    end

    @game_board.move(source, destination, current_player)
  end #get_move

  def coordinate_conversion(position)
    col_index, row_index  = position

    row_index = row_index.to_i

    if !col_index.between?('a','h') || !row_index.between?(1,8)
      raise "Invalid square index"
    end

    [@rows_hash[row_index], @columns_hash[col_index]]
  end #coordinate_conversion

  def generate_coordinate_hashes
    @columns_hash = {}
    column_number = 0
    ('a'..'h').each do |letter|
      @columns_hash[letter] = column_number
      column_number += 1
    end

    @rows_hash = {}
    row_number = 7
    (1..8).each do |row|
      @rows_hash[row] = row_number
      row_number -= 1
    end
  end #generate_coordinate_hashes

  def save
    begin
      puts "Enter a file name:"
      file_name = gets.chomp
      File.open(file_name, 'w') { |file| file.write(self.to_yaml)}
      abort
    rescue => e
      puts e.message
      retry
    end
  end

end #Chess

if __FILE__ == $PROGRAM_NAME

  begin
    system "clear"
    puts "Enter a save file if you would like to resume a game (else ENTER)"
    save_file = gets.chomp

    if save_file.empty?
      game = Chess.new
    else
      game = YAML::load_file(save_file)
    end
  rescue => e
    puts e.message
    retry
  end

  game.play

end
