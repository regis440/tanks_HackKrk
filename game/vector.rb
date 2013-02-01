class Vector
	attr_accessor :x, :y

	def initialize(x = 0, y = 0)
		@x = x
		@y = y
	end

	def translate(tx, ty)
		@x += tx
		@y += ty

		self
	end

	def translate_x(tx)
		@x += tx
		self
	end

	def translate_y(ty)
		@y += ty
		self
	end
end