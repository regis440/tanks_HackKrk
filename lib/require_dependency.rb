module Loader
	def require_dependency( dir )
		libs_path = File.expand_path( "../../#{dir}/**/*.rb", __FILE__)
		load_libs = Dir[ libs_path ]

		load_libs.each do |lib|
			require lib
		end
	end
end