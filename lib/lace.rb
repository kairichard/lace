require "lace/utils"
require "lace/exceptions"
require "lace/version"

module Lace extend self
  attr_accessor :failed
  alias_method :failed?, :failed
end


