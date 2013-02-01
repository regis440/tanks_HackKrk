class Hash

	def symbolize_keys!
		keys.each do |key|
			value = delete(key)
			self[key.to_sym] = value.is_a?(Hash) ? value.symbolize_keys! : value
		end
		self
	end

	def transform_keys!(&block)
		keys.each do |key|
			value = delete(key)
			self[yield(key)] = value.is_a?(Hash) ? value.transform_keys! : value
		end
		self
	end
end