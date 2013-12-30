require 'erb'

require 'koon/dotty'
require 'koon/exceptions'

INSPECT = <<-EOS
Inspection of simple:
  active:      <%= dotty.is_active? %>
  flavors:     <%= dotty.flavors %>
  version:     <%= dotty.version %>
  upgradeable: <%= dotty.upgradeable? %>
  manifest:    <%= dotty.manifest %>
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
    flavors_as_string or "nil"
  end

  def flavors_as_string
    if @pkg.facts.flavors
      return @pkg.facts.flavors.join ", "
    end
  end

  def version
    @pkg.facts.version or 'n/a'
  end

  def upgradeable?
    @pkg.is_git_repo?
  end

  def manifest
    return @pkg.facts.facts_file
  end
end
