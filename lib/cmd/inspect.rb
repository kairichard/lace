require 'erb'

require 'lace/package'
require 'lace/exceptions'

INSPECT = <<-EOS
Inspection of <%= package.name %>:
  active:      <%= package.is_active? %>
  flavors:     <%= package.flavors %>
  version:     <%= package.version %>
  homepage:    <%= package.homepage %>
  upgradeable: <%= package.upgradeable? %>
  manifest:    <%= package.manifest %>
EOS

module Lace extend self
  def inspect
    resource = ARGV.shift
    raise ResourceNotSpecified unless resource
    package = PackagePresenter.new Package.new(resource, false)
    puts ERB.new(INSPECT).result(binding)
  end
end

class PackagePresenter
  attr_accessor :pkg

  def initialize obj
    @pkg = obj
  end

  def name
    @pkg.name
  end

  def is_active?
    pkg.is_active?
  end

  def flavors
    flavors_as_string.empty? ? "nil" : flavors_as_string
  end

  def flavors_as_string
    if @pkg.facts.flavors
      return @pkg.facts.flavors.join ", "
    end
  end

  def version
    @pkg.facts.version or 'n/a'
  end

  def homepage
    @pkg.facts.homepage or 'n/a'
  end

  def upgradeable?
    @pkg.is_git_repo?
  end

  def manifest
    @pkg.facts.facts_file
  end
end
