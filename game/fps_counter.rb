class FpsCounter
	attr_reader :fps, :dt

	def initialize
		@fps = 0
		@dt  = 0
		@prev_time = Gosu::milliseconds()
		
		@accu_fps = 0
		@accu_time = 0
	end

	def update
		@accu_fps += 1
		@current_time = Gosu::milliseconds()
		@dt = @current_time - @prev_time
		@prev_time = @current_time
		@accu_time += @dt

		if @accu_time > 1000
			@accu_time -= 1000
			@fps = @accu_fps
			@accu_fps = 0
		end
	end
end