require 'lace/package'
require 'lace/exceptions'

module Lace extend self
	def install
		resource = ARGV.shift
		raise ResourceNotSpecified if not resource
		PackageUtils.install resource, ARGV
	end
end
