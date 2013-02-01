require_relative 'zorder'
require_relative 'fps_counter'
require_relative 'game_state_manager'

class GameWindow < Gosu::Window
	attr_accessor :debug_font, :options
	attr_accessor :background_color
	attr_reader   :fps_counter
	attr_reader   :state_manager
	attr_reader   :screen_size
	attr_reader   :half_screen_size
	attr_reader   :font_height

	def initialize(*args)
		super Settings.window[:width], Settings.window[:height], Settings.window[:fullscreen], 1000.0 / Settings.window[:frequency]
		self.caption = Settings.window[:caption]

		@debug_font = Gosu::Font.new( self, Gosu::default_font_name, 45 );

		@options = args.extract_options!
		@options[:debug] = true unless @options.has_key?(:debug)

		@fps_counter = FpsCounter.new
		@state_manager = GameStateManager.new

		@background_color = Gosu::Color::BLACK
		@screen_size = Vector.new(Settings.window[:width], Settings.window[:height])
		@half_screen_size = Vector.new(Settings.window[:width]/2, Settings.window[:height]/2)

		@font_height = @debug_font.height

		$game = self
	end

	def debug?
		options[:debug]
	end

	def debug=(value)
		options[:debug] = value
	end

	def update
		fps_counter.update

		state_manager.update
	end

	def draw
		draw_quad( 0,     0, 	  background_color,
				   width, 0,   	  background_color,
				   width, height, background_color,
				   0, 	  height, background_color, ZOrder::Background )

		state_manager.draw

		if debug?
			debug_font.draw( "Fps: #{fps}, dt: #{dt}", 10, 10, ZOrder::UI )
			debug_font.draw( "Mouse position [#{mouse_x}, #{mouse_y}]", 10, 10 + debug_font.height, ZOrder::UI )
		end
	end

	def debug_print(text, x, y)
		debug_font.draw( text, x, y, ZOrder::UI )
	end

	def button_down(id)
		state_manager.button_down(id)
	end

	def button_up(id)
		state_manager.button_up(id)
	end

	def needs_cursor?
		true
	end

	def fps
		fps_counter.fps
	end

	def dt
		fps_counter.dt 
	end

	def screen_width
		Settings.window[:width]
	end

	def screen_height
		Settings.window[:height]
	end
end