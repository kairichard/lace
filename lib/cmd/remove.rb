require 'lace/package'
require 'lace/exceptions'

module Lace extend self
	def remove
		package_name = ARGV.shift
		raise ResourceNotSpecified unless package_name
		PackageUtils.remove package_name
	end
end

