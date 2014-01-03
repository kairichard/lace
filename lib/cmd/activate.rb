
require 'koon/dotty'
require 'koon/exceptions'

module Zimt extend self
	def activate
		dotty_name = ARGV.shift
		raise ResourceNotSpecified if not dotty_name
		PackageUtils.activate dotty_name, ARGV
	end
end

