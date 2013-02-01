class GameState
	def self.input( *args )
		
		raise ArgumentError, "No mappings passed in" if args.empty?
		input_mappings = args.extract_options!

		input_mappings.each do |key, action|
			raise ArgumentError, "No key #{key} defined" unless defined?("#Gosu::Kb#{key.to_s.camelize}")
		end

		input_mappings.transform_keys! { |key| "Gosu::Kb#{key.to_s.camelize}".constantize }


		if args.empty? or args.first == :up
			self.inputs_up.push input_mappings
		else
			self.inputs_down.push input_mappings
		end
	end

	def self.menu( *args )
		@menu ||= []

		raise ArgumentError, "No menu items passed in" if args.empty?

		@menu_items = args.extract_options!
	end

	def self.inputs_down
		@inputs_down ||= []
	end

	def self.inputs_up 
		@inputs_up ||= []
	end

	def self.menu_items
		@menu_items ||= []
	end

	def activate
		puts "activate: #{self.class.name}"
	end

	def deactivate
		puts "deactivate: #{self.class.name}"
	end

	def update
	end

	def draw
		draw_menu_items
	end

	def button_down(id)
		puts "input down"
		dispatch_inputs_down(id)
	end

	def button_up(id)
		dispatch_inputs_up(id)
	end

	def button_down?(id)
		game.button_down?(id)
	end

	def game
		$game
	end

	def gosu_window
		$game
	end

	def state_manager
		$game.state_manager
	end

	private
		def inputs_down
			self.class.inputs_down
		end

		def inputs_up
			self.class.inputs_up
		end

		def menu_items
			self.class.menu_items
		end

		def dispatch_inputs_down(id)
			dispatch_inputs(inputs_down, id)
		end

		def dispatch_inputs_up(id)
			dispatch_inputs(inputs_up, id)
		end

		def dispatch_inputs(inputs, id)
			inputs.each do |mappers|
				mappers.each do |key, action|
					if id == key
						self.send( action ) if self.respond_to?( action )
					end
				end
			end
		end

		def draw_menu_items
			return if menu_items.empty?

			height = game.half_screen_size.x 
			line_height = game.font_height
			height -= menu_items.size / 2 * line_height
			width = game.half_screen_size.y

			menu_items.each do |name, action|
				game.debug_print name, width, height 
				height += line_height
			end
		end
end