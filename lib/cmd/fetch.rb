require 'zimt/package'
require 'zimt/exceptions'

module Zimt extend self
	def fetch
		resource = ARGV.shift
		raise ResourceNotSpecified if not resource
		PackageUtils.fetch resource, ARGV
	end
end
