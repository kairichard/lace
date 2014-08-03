require 'lace/package'
require 'lace/exceptions'

module Lace extend self
	def upgrade
    require 'cmd/list'
    if Lace.active_packages.empty?
      upgrade_lace_folder
    else
      onoe "Please deactivate all packages before continuing"
      Lace.failed = true
    end
	end
  def upgrade_lace_folder
    old_dir = Pathname.new(ENV["HOME"])/".cassias"
    if old_dir.exist?
      File.rename old_dir, Lace.pkgs_folder
      old_dir.rmdir_if_possible
    end
  end
end
