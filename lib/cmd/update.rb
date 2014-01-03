require 'koon/dotty'
require 'koon/exceptions'

module Zimt extend self
	def update
		resource = ARGV.shift
		raise ResourceNotSpecified if not resource
		DottyUtils.update resource, ARGV
	end
end
