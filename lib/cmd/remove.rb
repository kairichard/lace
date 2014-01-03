require 'koon/package'
require 'koon/exceptions'

module Zimt extend self
	def remove
		package_name = ARGV.shift
		raise ResourceNotSpecified if not package_name
		PackageUtils.remove package_name, ARGV
	end
end

