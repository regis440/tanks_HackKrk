require_relative 'config/boot'
require_relative 'g2liveu/g2liveu_client'
require_relative 'tank_game_state'
module Tanks
	GameId 			= 3
	LeaderboardId 	= 5
end

class MainMenu < GameState

	input 	:escape => :close_me, 
			:q => :close_me,
			:p => :play,
			:s => :send_score

	menu 	"Main Menu" => :nop,
			"Play Game [p]" => :play,
			"Send Score [s]" => :send_score,
			"Exit [q]" => :exit

	def close_me
		puts "Fuck close me"
		game.close
	end

	def play
		state_manager.push NextLevelMenu.new 0
	end

	def draw
		super
	end

	def button_up(id)
		super
		puts id
		if Xbox360::A== id
			play
		end
	end 

	def send_score
		G2Liveu::Leaderboard.send_score :leaderboardid => Tanks::LeaderboardId, :login => "hackkrk", :score => 100

		state_manager.push ScoresMenu
	end
end

class ScoresMenu < GameState
	input :escape => :back

	def initialize
		@scores =  G2Liveu::Leaderboard.query_scores :leaderboardid => Tanks::LeaderboardId

		@scores.each do |score|
			puts "#{score[:rank]}.) #{score[:login]} - #{score[:score]}"
		end
	end

	def back
		state_manager.pop
	end

	def draw

		return if @scores.empty?

		height 		=  game.half_screen_size.x 
		line_height =  game.font_height
		height 		-= menu_items.size / 2 * line_height
		width 		=  game.half_screen_size.y

		@scores.each do |score|
			game.debug_print "#{score[:rank]}.) #{score[:login]} - #{score[:score]}", width, height 
			height += line_height
		end
	end

	def button_up(id)
		if Xbox360::B == id
			back
		end
		if Gosu::KbEscape == id
			back
		end
	end 

end

class NextLevelMenu < GameState
	def initialize lvl
		@lvl = lvl
	end

	def back
		state_manager.pop
	end

	def draw

		height 		=  game.half_screen_size.x 
		line_height =  game.font_height
		height 		-= menu_items.size / 2 * line_height
		width 		=  game.half_screen_size.y

		game.debug_print "Level: #{@lvl+1}", width, height 
	end
	
	def button_down(id)
		state_manager.pop
		state_manager.push TankMap.new @lvl
	end
end

class SettingsMenu < GameState
end

=begin 
class GameMenu < GameState

	input :down,	:left  => :turn_left,
		  			:right => :turn_right,
		  			:up    => :turn_up,
		  			:down  => :turn_down,
		  			:space => :jump

	input :up, :escape => :back

	def initialize
		super

		@position = game.half_screen_size
	end

	def upate
	end
	
	def draw
		game.debug_print "Game Menu", @position.x, @position.y
	end

	def turn_left
		puts "turn left"
		@position.translate_x(-10)
	end

	def turn_right
		puts "turn right"
		@position.translate_x(10)
	end

	def turn_up
		puts "turn up"
		@position.translate_y(-10)
	end

	def turn_down
		puts "turn down"
		@position.translate_y(10)
	end

	def jump
		puts "jump"
	end

	def back
		state_manager.pop
	end
end
=end 

class TanksGame < GameWindow
	def initialize
		super :debug => false
		state_manager.push MainMenu
	end
end

if ARGV.size == 0
	puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	puts "!!    Tell me palyer name!     !!"
	puts "!! Example: ruby game.rb Filip !!"
	puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	return
end
TanksGame.new.show