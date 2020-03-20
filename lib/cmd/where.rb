require 'lace/package'
require 'lace/exceptions'

module Lace extend self
  def where
    package_name = ARGV.shift
    raise ResourceNotSpecified unless package_name
    begin
      package = Package.new(package_name, false)
      puts "#{package.path}"
    rescue PackageFactsNotFound => e
      onoe "asd"
      Lace.failed = true
    end
  end
end
