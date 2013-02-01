require_relative 'peer'

module Network
	module Defaults
		Address 		= "127.0.0.1"
		Port 			= 30000
		MaxConnections 	= 8
		MaxPacketSize   = 1024
		PriorityMax     = 0
		PriorityDefault = 10
		PriorityLow     = 100
	end

	class Message
		attr_reader :timestamp, :attributes, :destination, :priority

		def initialize( options = {} )
			@timestamp   = Gosu::milliseconds
			@destination = attributes[:destination] 
			@destination = attributes[:priority] || Defaults::PriorityDefault
			@attributes  = options
		end
	end

	class Host
		attr_reader :socket, :peers
		attr_reader :max_connections, :max_packet_size
		attr_reader :address, :port
		attr_reader :message_queue
		attr_accessor :debug

		def self.create(options, &block)
			Host.new(options)
		end

		def self.start(options, &block)
			host = Host.new(options)
			host.start 
			host
		end

		def initialize(options = {})

			@address = options[:address] || Network::Defaults::Address
			@port    = options[:port] || Network::Defaults::Port

			@socket  = options[:socket]
			@peers   = []

			@max_connections = options[:max_connections] || Network::Defaults::MaxConnections
			@max_packet_size = options[:max_packet_size] || Network::Defaults::MaxPacketSize

			@message_queue = []

			@debug = options[:debug] || true
		end

		def start
			begin
				@socket = TCPServer.new( address, port )
			rescue
				on_error $!
			end

			self
		end

		def stop
			if started?
				begin
					@socket.close
				rescue
					on_error $!
				end
			end
			self
		end

		def started?
			@socket and !@socket.closed?
		end

		def connected?(peer)
			peers.include?(peer)
		end

		def debug?
			@debug
		end

		def send(peer, message)
			@message_queue << Message.new( :destination => peer,
										   :raw => false,
										   :data => message )
		end

		def send_raw(peer, data)
			@message_queue << Message.new( :destination => peer,
			 							   :raw => true,
			 							   :data => data )
		end

		def broadcast(message)
			@peers.each do |peer|
				send(peer, message)
			end
		end

		def broadcast_raw(data)
			@peers.each do |peer|
				send_raw(peer, data)
			end
		end 

		#
		# Reactor pattern
		#
		def update
			if started?
				accept_peers
				send_messages
				receive_messages
			end

			self
		end

		def on_error(error)
			"[Host@#{address}:#{port}] Error occurred: #{error}" if debug?
		end

		def on_peer_connected(peer) 
			"[Host@#{address}:#{port}] New Peer connected from : #{perr}" if debug?
		end

		def on_peer_disconnected(peer)  
			"[Host@#{address}:#{port}] Peer disconnected from: #{peer}" if debug?
		end

		def on_peer_message(peer, message)
			"[Host@#{address}:#{port}] Host received mesasge from: #{peer}. Content: #{message.inspect}" if debug?
		end

		def on_peer_raw(peer, data)
			"[Host@#{address}:#{port}] Host received raw data from: #{peer}" if debug?
		end

		def on_max_conenctions
			"[Host@#{address}:#{port}] Maximum number of peers connected : #{max_connections}" if debug?
		end

		private
			def accept_peers
				if @sockets.size < @max_connections
					begin
						peer_socket = @socket.accept_nonblock
						if peer_socket
							af, port, host, addr = peer_socket.addr 

							peer = Peer.new(:address => addr, :port => port, :socket => peer_socket)
							@peers << peer 

							on_peer_connected peer
						end
					rescue
						on_error $! 
					end
				end
			end

			def send_messages
				if message_queue.empty?
					return
				end

				begin

				rescue Errno::ECONNABORTED, Errno::ECONNRESET, IOError
					on_peer_disconnected peer
				rescue
					on_error $!
				end
			end

			def receive_messages
				@peers.each do |peer|
					if IO.select peer.socket, nil, nil, 0 
						begin
							packet = peer.socket.recvfrom max_packet_size
							if packet
								parse_packet peer, packet 
							end
						rescue Errno::ECONNABORTED, Errno::ECONNRESET, IOError
							on_peer_disconnected peer
						rescue
							on_error $!
						end
					end 
				end
			end

			def parse_packet(peer, packet)
			end

	end

	def create_host( options, &block )
		Host.create( options, &block )
	end

	def start_host( options, &block )
		Host.start( options, &block )
	end
end