require 'erb'

require 'koon/dotty'
require 'koon/exceptions'

INSPECT = <<-EOS
Inspection of simple:
  active:      <%= dotty.is_active? %>
  flavors:     <%= dotty.flavors %>
  version:     <%= dotty.version %>
  upgradeable: <%= dotty.upgradeable? %>
  manifest:    HOME/installed_cassias/simple/dotty.yml
EOS

module Koon extend self
	def inspect
		resource = ARGV.shift
		raise ResourceNotSpecified if not resource
    dotty = PackagePresenter.new Dotty.new(resource, false)
    puts ERB.new(INSPECT).result(binding)
	end
end

class PackagePresenter
  attr_accessor :pkg
  def initialize obj
    @pkg = obj
  end
  def is_active?
    pkg.is_active?
  end
  def flavors
    "nil"
  end
  def version
    'n/a'
  end
  def upgradeable?
    false
  end
  def manifest
    "HOME/installed_cassias/simple/dotty.yml"
  end
end
