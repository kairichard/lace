require 'koon/dotty'
require 'koon/exceptions'

module Zimt extend self
	def fetch
		resource = ARGV.shift
		raise ResourceNotSpecified if not resource
		DottyUtils.fetch resource, ARGV
	end
end
