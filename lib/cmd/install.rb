require 'zimt/package'
require 'zimt/exceptions'

module Zimt extend self
	def install
		resource = ARGV.shift
		raise ResourceNotSpecified if not resource
		PackageUtils.install resource, ARGV
	end
end
