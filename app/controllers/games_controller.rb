require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = (0...10).map { ('a'..'z').to_a[rand(26)] }
  end

  def score
    @result_answer = params[:inputfield]
    @start_time = Time.parse params[:start_time]
    @end_time = Time.now
    @time_difference = @end_time - @start_time
    @grid = params[:letters].chars
    @results = run_game(@result_answer, @grid, @start_time, @end_time)
  end

  def generate_grid(grid_size)
  # TODO: generate random grid of letters
  Array.new(grid_size) { ('A'..'Z').to_a.sample }
end

def included?(guess, grid)
  guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
end

def compute_score(attempt, time_taken)
  time_taken > 60.0 ? 0 : attempt.size * (1.0 - time_taken / 60.0)
end

def run_game(attempt, grid, start_time, end_time)
  # TODO: runs the game and return detailed hash of result (with `:score`, `:message` and `:time` keys)
  result = { time: end_time - start_time }

  score_and_message = score_and_message(attempt, grid, result[:time])
  result[:score] = score_and_message.first
  result[:message] = score_and_message.last

  result
end

def score_and_message(attempt, grid, time)
  if included?(attempt.downcase, grid)
    if english_word?(attempt)
      score = compute_score(attempt, time)
      [score, 'well done']
    else
      [0, 'not an english word']
    end
  else
    [0, 'not in the grid']
  end
end

def english_word?(word)
  response = open("https://wagon-dictionary.herokuapp.com/#{word}")
  json = JSON.parse(response.read)
  return json['found']
end
end
