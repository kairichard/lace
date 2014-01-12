require 'lace/package'
require 'lace/exceptions'

module Lace extend self
	def install
		package_name = ARGV.shift
		PackageUtils.install package_name
	end
end
