require 'koon/package'
require 'koon/exceptions'

module Zimt extend self
	def update
		resource = ARGV.shift
		raise ResourceNotSpecified if not resource
		PackageUtils.update resource, ARGV
	end
end
