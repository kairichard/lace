require 'lace/package'
require 'lace/exceptions'

module Lace extend self
  def setup
    package_name = ARGV.shift
    PackageUtils.setup package_name
  end
end
