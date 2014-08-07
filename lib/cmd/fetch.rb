require 'lace/package'
require 'lace/exceptions'

module Lace extend self
	def fetch
		resource = ARGV.shift
		raise ResourceNotSpecified unless resource
		package_name, target_folder = PackageUtils.fetch(resource)
    begin
        Package.new(package_name, false)
    rescue PackageFactsNotFound => e
        onoe e.message
        onoe "Removing fetched files"
        FileUtils.rm_rf(target_folder)
        Lace.failed = true
    end
	end
end
