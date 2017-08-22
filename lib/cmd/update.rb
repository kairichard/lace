require 'lace/package'
require 'lace/exceptions'

module Lace extend self
  def update
    resource = ARGV.shift
    raise ResourceNotSpecified unless resource
    PackageUtils.update resource
  end
end
