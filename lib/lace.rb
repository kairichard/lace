require "lace/utils"
require "lace/exceptions"
require "lace/version"

module Lace extend self
  attr_accessor :failed
  alias_method :failed?, :failed

  def self.pkgs_folder
    packages_folder = Pathname.new(ENV["HOME"]).join(".lace.pkgs")

    if ENV["LACE_FOLDER"]
      packages_folder = Pathname.new(ENV["LACE_FOLDER"])
    end
    packages_folder
  end

  def self.pstore
    @pstore ||= PStore.new(pkgs_folder/".lace.pstore")
  end
end


