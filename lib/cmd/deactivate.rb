require 'lace/package'
require 'lace/exceptions'

module Lace extend self
	def deactivate
		package_name = ARGV.shift
		raise ResourceNotSpecified unless package_name
		PackageUtils.deactivate package_name
	end
end

