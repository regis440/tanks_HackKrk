module Network
	class Peer
		attr_reader :socket
		attr_reader :address, :port

		def initialize(options = {})
			@address = options[:address]
			@port    = options[:port]
			@socket  = options[:socket]
		end

		def to_s
			"[Peer@#{address}:#{port}]"
		end
	end
end