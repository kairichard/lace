require 'koon/package'
require 'koon/exceptions'

module Zimt extend self
	def deactivate
		package_name = ARGV.shift
		raise ResourceNotSpecified if not package_name
		PackageUtils.deactivate package_name, ARGV
	end
end

