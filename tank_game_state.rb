
require 'rubygems'
require 'gosu'
require 'tmx'

def is_enemy_on_pos map, x, y

	map.object_groups["tanks"].each do |obj|
		if (obj[:x]+1)/2 == x && (obj[:y]-1)/2 == y 
			return true
		end
	end
	false
end

def is_player_on_pos map, x, y

	map.object_groups["players"].each do |obj|
		if (obj[:x]+1)/2 == x && (obj[:y]-1)/2 == y 
			return true
		end
	end
	false
end

def is_collision layer, pos_x, pos_y

if pos_y <= 0
return true
end
if pos_x <= 0
return true
end
if pos_y >= 800
return true
end
if pos_x >= 800
return true
end
	if layer[pos_x/$tile_size,(pos_y-1)/$tile_size] == 2
			if layer[(pos_x)/$tile_size,(pos_y-1)/$tile_size] == 2
				if layer[pos_x/$tile_size,(pos_y-$tile_size)/$tile_size] == 2
					if layer[(pos_x)/$tile_size,(pos_y-$tile_size)/$tile_size] == 2
						return false
					end
				end
			end
		end
		true
end


def move_player_on_pos map, layer, dir

	$tile_size = 32 
	map.object_groups["players"].each do |obj|
		new_pos_x = obj[:x]
		new_pos_y = obj[:y]
		if dir == 0
			new_pos_y = obj[:y] - $tile_size
		end
		if dir == 1
			new_pos_y = obj[:y] + $tile_size
		end
		if dir == 2
			new_pos_x = obj[:x] - $tile_size
		end
		if dir == 3
			new_pos_x = obj[:x] + $tile_size
		end
# => collisonmanager X-D
		if is_collision( layer, new_pos_x, new_pos_y) == false
			obj[:x] = new_pos_x
			obj[:y] = new_pos_y
		end

	end
end


module Xbox360
	A = 65557
	B = 65558
	Up = 65546
	Down = 65547
	Right = 65549
	Left = 65548
	TriggerUp = 65544
	TriggerDown = 65545
	TriggerLeft = 65542
	TriggerRight = 65543
end

class TankMap < GameState
	
	attr_reader :map

	ShootUp    = 0
	ShootDown  = 1
	ShootLeft  = 2
	ShootRight = 3

	GoUp    = 0
	GoDown  = 1
	GoLeft  = 2
	GoRight = 3

	def initialize lvl
		#super
		@lvl = lvl
		caption = "Tanks"
		$bullet_num = 0
		@shoot_dir = ShootUp
		$player_score = 0 if lvl == 0
		@map = Tmx::Map.new gosu_window, "levels/tanks_#{lvl}.tmx"
	end

	def updateBullets layer
		map.object_groups["bullets"].each do |bullet|
			bullet[:x] -= 32  if bullet[:shoot_dir] == ShootLeft
			bullet[:x] += 32  if bullet[:shoot_dir] == ShootRight
			bullet[:y] -= 32  if bullet[:shoot_dir] == ShootUp
			bullet[:y] += 32  if bullet[:shoot_dir] == ShootDown

			 if is_collision( layer, bullet[:x], bullet[:y]) == true
					map.object_groups["bullets"].remove  bullet
			 else
			 	if bullet[:owner] == "player"
					map.object_groups["tanks"].each do |tank|
						if bullet[:x] == tank[:x]
							if bullet[:y] == tank[:y]
								map.object_groups["tanks"].remove tank
								map.object_groups["bullets"].remove  bullet
								$player_score += 100 #premia kill tank
								if map.object_groups["tanks"].size == 0
									$player_score += 500*(@lvl+1) #premia level finish
									new_lvl = @lvl+1
									if !File.exists? "levels/tanks_#{new_lvl}.tmx"
										new_lvl = 0
									end
									state_manager.pop
									state_manager.push NextLevelMenu.new new_lvl
								end
							end
						end	
					end
				elsif bullet[:owner] == "tank"
					map.object_groups["players"].each do |player|
						if bullet[:x] == player[:x]
							if bullet[:y] == player[:y]
									map.object_groups["players"].remove player
									map.object_groups["bullets"].remove  bullet
									state_manager.pop
									G2Liveu::Leaderboard.send_score :leaderboardid => Tanks::LeaderboardId,
																	:login => ARGV[0],
																	:score => $player_score
									state_manager.push ScoresMenu
							end
						end	
					end
				end
			end
		end
	end
	
	def updateTanks layer
		map.object_groups["players"].each do |player|
			map.object_groups["tanks"].each do |tank|

#####################ATACK!!!!!!!!!################################				
				if player[:x] == tank[:x]
					if player[:y] < tank[:y]
						$bullet_num += 1
						bullet = {
									:name => "bullet" +  "#{$bullet_num}",
									:x => tank[:x],
									:y => tank[:y],
									:width => 32,
									:height => 32,
									:gid => 5,
									:shoot_dir => ShootUp,
									:owner => "tank"
								}
								map.object_groups["bullets"].add bullet
					else
						$bullet_num += 1
						bullet = {
									:name => "bullet" +  "#{$bullet_num}",
									:x => tank[:x],
									:y => tank[:y],
									:width => 32,
									:height => 32,
									:gid => 5,
									:shoot_dir => ShootDown,
									:owner => "tank"
								}
								map.object_groups["bullets"].add bullet
					end
				elsif player[:y] == tank[:y]
					if player[:x] < tank[:x]
						$bullet_num += 1
						bullet = {
									:name => "bullet" +  "#{$bullet_num}",
									:x => tank[:x],
									:y => tank[:y],
									:width => 32,
									:height => 32,
									:gid => 5,
									:shoot_dir => ShootLeft,
									:owner => "tank"
								}
								map.object_groups["bullets"].add bullet
					else
						$bullet_num += 1
						bullet = {
									:name => "bullet" +  "#{$bullet_num}",
									:x => tank[:x],
									:y => tank[:y],
									:width => 32,
									:height => 32,
									:gid => 5,
									:shoot_dir => ShootRight,
									:owner => "tank"
								}
								map.object_groups["bullets"].add bullet
					end
				end
#####################FOLLOW!!!!!!!!!################################	
				tank[:cycle] ||= 0
				tank[:cycle] =  tank[:cycle] + 1
				
				if tank[:cycle]  > (rand( 10 ) + 5)
					tank[:cycle] = 0
					dir_tank = rand 3
					new_pos_x = tank[:x] 
					new_pos_y = tank[:y]
					if dir_tank == GoUp
						new_pos_y -= $tile_size
					elsif dir_tank == GoDown
						new_pos_y += $tile_size
					elsif dir_tank == GoLeft
						new_pos_x -= $tile_size
					elsif dir_tank == GoRight
						new_pos_x += $tile_size
					end
					if is_collision( layer, new_pos_x, new_pos_y ) == false
						tank[:x] = new_pos_x
						tank[:y] = new_pos_y
					end
				end
				
			end
		end
	end
	def update
		dir = 4

		if button_down? Xbox360::Up
			dir = 0
		end
		if button_down? Xbox360::Down
			dir = 1
		end
		if button_down? Xbox360::Left
			dir = 2
		end
		if button_down? Xbox360::Right
			dir = 3
		end

		
		if button_down? Xbox360::TriggerUp
			@shoot_dir = ShootUp
		end
		if button_down? Xbox360::TriggerDown
			@shoot_dir = ShootDown
		end
		if button_down? Xbox360::TriggerLeft
			@shoot_dir = ShootLeft
		end
		if button_down? Xbox360::TriggerRight
			@shoot_dir = ShootRight
		end

			
		layer = @map.layers["Tile Layer 1"]
		move_player_on_pos @map, layer, dir
		updateBullets layer
		updateTanks layer
	end

	def shoot x, y
		$bullet_num += 1
			bullet = {
			:name => "bullet" +  "#{$bullet_num}",
			:x => x,
			:y => y,
			:width => 32,
			:height => 32,
			:gid => 6,
			:shoot_dir => @shoot_dir,
			:owner => "player"
		}
		map.object_groups["bullets"].add bullet
		
	end

	def draw
		@map.draw 0, 0
	end

	def button_down(id)

	end

	def button_up(id)
		map.object_groups["players"].each do |obj| shoot obj[:x], obj[:y] end if Xbox360::A == id
	end
end