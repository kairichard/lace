# frozen_string_literal: true

require 'lace/package'
require 'lace/exceptions'

module Lace
  module_function

  def setup
    package_name = ARGV.shift
    PackageUtils.setup package_name
  end
end
