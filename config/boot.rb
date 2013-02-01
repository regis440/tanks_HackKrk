#
# Load gems
#
require 'rubygems'

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

if defined?(Bundler)
	env = :development

	ARGV.each do |arg|
		if arg == "production"
			env = :production
		elsif arg == "test"
			env = :test
		end
	end

	Bundler.require
end

#
# Load lib
#
require_relative '../lib/require_dependency'
include Loader

require_dependency('lib')

#
# Load settings
#
require_relative 'settings'

::Settings.load()

#
# Load initialzers
#
require_dependency('config/initialzers')

#
# Load game library
#
require_dependency('game')