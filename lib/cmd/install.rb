require 'koon/download_strategy'
require 'koon/exceptions'
module Koon extend self
	def install
		resource = ARGV.shift
		raise ResourceNotSpecified if not resource
		download_strategy = DownloadStrategyDetector.detect(resource)
		download_strategy = download_strategy.new(resource)
		download_strategy.fetch
	end
end
