# frozen_string_literal: true

gem 'ruby-fann', '=1.3.2'
require 'ruby-fann'
require 'csv'
require 'progress_bar'
require 'tty-pie'
require_relative './game_board'
require_relative './progress_bar'
require_relative './artificial_intelligence'

class Interface
  def initialize
    @game = GameBoard.new(@players)
  end

  def start
    players_arr = %w[Human AI]
    @player1 = players_arr.shuffle!.pop
    @player2 = players_arr.join
    puts ' '
    puts '--------------------------------'
    puts 'New game! Or press "q" and Enter to finish.'
    puts "'Player X' is #{@player1} & 'Player O' is #{@player2}."
    display_board
  end

  def display_board
    puts "\n"
    puts " #{@game.board[0]} | #{@game.board[1]} | #{@game.board[2]} "
    puts ' ---------- '
    puts " #{@game.board[3]} | #{@game.board[4]} | #{@game.board[5]} "
    puts ' ---------- '
    puts " #{@game.board[6]} | #{@game.board[7]} | #{@game.board[8]} "
    puts "\n"
  end

  def turn
    if @game.current_player == :X && @player1 == 'Human'
      print "#{@player1}, choose a position between 1-9: "
      spot = quit_game(gets.strip)
    elsif @game.current_player == :O && @player1 == 'AI'
      print "#{@player2}, choose a position between 1-9: "
      spot = quit_game(gets.strip)
    else
      spot = AI.neural_network(
        @game.counter,
        @game.place?(4),
        @game.board,
        @game.fork_danger_1?,
        @game.fork_danger_2?,
        @game.fork_danger_3?,
        Starting::Array_of_games
      )
    end
    spot = @game.board_index(spot)
    if @game.move_allowed?(spot)
      @game.enter_move(spot, @game.current_player)
      display_board
    else
      puts 'Invalid input value! Please try again.'
      display_board
      turn
    end
  end

  def quit_game(spot)
    if spot == 'q'
      puts 'It was nice to play with you. Bye.'
      exit
    else
      spot
    end
  end

  def play
    turn until @game.total
    if @game.won?
      if @game.who_has_won? == :X && @player1 == 'Human' ||
         @game.who_has_won? == :O && @player2 == 'Human'
        puts 'Congratulations, Human! You Won.'
        AI.recreate_games_log
      else
        puts 'Congratulations, AI! You Won.'
      end
    elsif @game.draw?
      puts 'Game over! Draw.'
    end
    sleep 5
    Starting.beginning_of_game
  end
end
