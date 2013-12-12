helpers do

	# def cell_value(value)
	# 	value.to_i == 0 ? '' : value
	# end

	def colour_class(solution_to_check, puzzle_value, current_solution_value, solution_value)
		must_be_guessed = puzzle_value == ""
		tried_to_guess = current_solution_value != ""
		guessed_incorrectly = current_solution_value != solution_value
		if solution_to_check &&
			must_be_guessed &&
			tried_to_guess &&
			guessed_incorrectly
			'incorrect'
		elsif !must_be_guessed
			'value-provided'
		end
	end
end

