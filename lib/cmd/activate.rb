
require 'koon/package'
require 'koon/exceptions'

module Zimt extend self
	def activate
		package_name = ARGV.shift
		raise ResourceNotSpecified if not package_name
		PackageUtils.activate package_name, ARGV
	end
end

