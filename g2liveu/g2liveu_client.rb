require 'json'

require_relative '../lib/hash'

module G2Liveu
	module Settings
		Name = "g2liveu"
		Address = "78.133.245.199"
		Port 	= 80
	end
	class Leaderboard
		def self.send_score( options )
			RestClient.post( "http://#{G2Liveu::Settings::Address}:#{G2Liveu::Settings::Port}/#{G2Liveu::Settings::Name}/api/leaderboards/#{options[:leaderboardid]}/scores", {
					:user => {
						:login => options[:login],
						:uniqueid => "DEADBEEF"
					},
					:score => options[:score]
				}, {
					:content_type => :json,
					:accept => :json
					})
		end

		def self.query_scores( options )
			response = RestClient.get "http://#{G2Liveu::Settings::Address}:#{G2Liveu::Settings::Port}/#{G2Liveu::Settings::Name}/api/leaderboards/#{options[:leaderboardid]}/scores", :content_type => :json, :accept => :json
			scores = JSON.parse response
			scores.each do |score|
				score.symbolize_keys!
			end
		end
	end
end