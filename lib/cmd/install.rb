require 'koon/download_strategy'
require 'koon/dotty'
require 'koon/exceptions'

module Koon extend self
	def install
		resource = ARGV.shift
		raise ResourceNotSpecified if not resource
		dotty = Dotty.new resource, ARGV
		dotty.install
	end
end
