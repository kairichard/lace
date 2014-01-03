require 'koon/dotty'
require 'koon/exceptions'

module Zimt extend self
	def remove
		dotty_name = ARGV.shift
		raise ResourceNotSpecified if not dotty_name
		DottyUtils.remove dotty_name, ARGV
	end
end

