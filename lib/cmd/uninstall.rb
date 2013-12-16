require 'koon/dotty'
require 'koon/exceptions'

module Koon extend self
	def uninstall
		dotty_name = ARGV.shift
		raise ResourceNotSpecified if not dotty_name
		DottyUtils.uninstall dotty_name, ARGV
	end
end


