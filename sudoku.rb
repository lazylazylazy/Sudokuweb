require 'sinatra'
require 'sinatra/partial'
require 'rack-flash'
require 'newrelic_rpm'

require_relative './lib/sudoku'
require_relative './lib/cell'
require_relative './lib/helper'

set :partial_template_engine, :erb
enable :sessions
set :session_secret, "I'm the secret key to sign the cookie"
use Rack::Flash

def random_sudoku
	seed = (1..9).to_a.shuffle + Array.new(81-9, 0)
	sudoku = Sudoku.new(seed.join)
	sudoku.solve!
	sudoku.to_s.chars
end

def puzzle(sudoku)
	new_sudoku = sudoku
	rows = new_sudoku.each_slice(9).to_a
	rows.each do |row|
		until row.count("") == 3
			row[rand(0..8)] = ""
		end
	end
	rows.flatten
end

def box_order_to_row_order(cells)
	boxes = cells.each_slice(9).to_a
	(0..8).to_a.inject([]) {|memo, i | 
		first_box_index = i / 3*3
		three_boxes = boxes[first_box_index, 3]
		three_rows_of_three = three_boxes.map do |box|
			row_number_in_a_box = i % 3
			first_cell_in_the_row_index = row_number_in_a_box * 3
			box[first_cell_in_the_row_index, 3]
	end
	memo += three_rows_of_three.flatten
	}
end

def generate_new_puzzle_if_necessary
	return if session[:current_solution]
	sudoku = random_sudoku
	session[:solution] = sudoku
	session[:puzzle] = puzzle(sudoku)
	session[:current_solution] = session[:puzzle]
end

def prepare_to_check_solution
	@check_solution = session[:check_solution]
	if @check_solution
	flash[:notice] = "Incorrect values are highlighted in red"
	end
	session[:check_solution] = nil
end

get '/' do
	cells = params['cell']
	prepare_to_check_solution
	generate_new_puzzle_if_necessary
	# sudoku = random_sudoku
	# session[:solution] = sudoku
	@current_solution = session[:current_solution] || session[:puzzle]
	@solution = session[:solution]
  @puzzle = session[:puzzle]
	erb :index
end

get '/solution' do
	@current_solution = session[:solution]
	@solution = session[:solution]
  @puzzle = session[:puzzle]
	erb :index
end

post '/new-game' do
	session[:current_solution] = nil
	generate_new_puzzle_if_necessary
	redirect to '/'
	# reset the session
	# generate new puzzle
	# redirect to the homepage (using a get request)
end

post '/' do
	cells = box_order_to_row_order(params['cell'])
	session[:current_solution] = cells
	session[:check_solution] = true
	redirect to("/")
end