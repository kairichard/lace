require 'koon/dotty'
require 'koon/exceptions'

module Zimt extend self
	def deactivate
		dotty_name = ARGV.shift
		raise ResourceNotSpecified if not dotty_name
		PackageUtils.deactivate dotty_name, ARGV
	end
end

