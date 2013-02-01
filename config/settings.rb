require 'rubygems'

class MissingKeyError < StandardError
end

class Settings
	@@settings_path = ""
	@@settings  	= {}

	def self.load
		@@settings_path = File.dirname(__FILE__) + '/../config/settings.yml';
		raise IOError, "Settings file not found at path : #{@@settings_path}" unless File.exist?( settings_path )

		@@settings = ::YAML::load(File.read( settings_path ));
		@@settings.symbolize_keys!
	end

	def self.settings_path
		@@settings_path
	end

	def self.value!(key)
		raise MissingKeyError, "#{key.to_s} is not found in the settings file" unless @@settings.include?(key)
		@@settings[key]
	end

	def self.window
		value!(:window)
	end
end