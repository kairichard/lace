require 'zimt/package'
require 'zimt/exceptions'

module Zimt extend self
	def remove
		package_name = ARGV.shift
		raise ResourceNotSpecified if not package_name
		PackageUtils.remove package_name, ARGV
	end
end

