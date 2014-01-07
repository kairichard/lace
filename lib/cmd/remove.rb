require 'lace/package'
require 'lace/exceptions'

module Lace extend self
	def remove
		package_name = ARGV.shift
		raise ResourceNotSpecified if not package_name
		PackageUtils.remove package_name
	end
end

