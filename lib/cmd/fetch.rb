require 'lace/package'
require 'lace/exceptions'

module Lace extend self
	def fetch
		resource = ARGV.shift
		raise ResourceNotSpecified if not resource
		PackageUtils.fetch resource
	end
end
