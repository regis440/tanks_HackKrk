require_relative 'game_state'

class GameStateManager
	attr_reader :current_state, :previous_state, :states
	

	def initialize
		@current_state = nil
		@previous_state = nil

		@states = []
	end

	def push_state(state)
		state = state.new if state.is_a?(Class)

		if state 
			if @current_state
				@current_state.deactivate if @current_state.respond_to?(:deactivate)
				@previous_state = @current_state
			end

			@current_state = state
			@current_state.activate if @current_state.respond_to?(:activate) 
			@states.push current_state

			@current_state
		end
	end

	def pop_state
		if @current_state
			@current_state.deactivate if @current_state.respond_to?(:deactivate)
			
			last = @states.pop

			@current_state, @previous_state = @states.last(2)

			if @current_state
				@current_state.activate if @current_state.respond_to?(:activate)
			end

			last
		end
	end

	alias :push :push_state
	alias :pop  :pop_state


	def valid_state?
		current_state != nil
	end

	def update
		if current_state
			current_state.update if current_state.respond_to?(:update)
		end
	end

	def draw
		if current_state
			current_state.draw if current_state.respond_to?(:draw)
		end
	end

	def button_down(id)
		if current_state
			current_state.button_down(id) if current_state.respond_to?(:button_down)
		end
	end

	def button_up(id)
		if current_state
			current_state.button_up(id) if current_state.respond_to?(:button_up)
		end
	end

	def debug
		puts "States vector: "
		@states.each do |state|
			puts state.class.name
		end
		puts "current: #{@current_state.class.name}"
		puts "previous: #{@previous_state.class.name}"
	end

end