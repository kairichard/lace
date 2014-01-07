
require 'lace/package'
require 'lace/exceptions'

module Lace extend self
	def activate
		package_name = ARGV.shift
		raise ResourceNotSpecified if not package_name
		PackageUtils.activate package_name
	end
end

