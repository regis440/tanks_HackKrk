class String
	def underscore
		downcase.gsub(/\s+/, "_")
	end

	def camelize
    	self.split(/[^a-z0-9]/i).map{|w| w.capitalize}.join
  	end

  	def constantize
	  names = self.split('::')
	  names.shift if names.empty? || names.first.empty?

	  constant = Object
	  names.each do |name|
	    constant = constant.const_defined?(name) ? constant.const_get(name) : constant.const_missing(name)
	  end
	  constant
	end
end