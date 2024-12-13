require 'lace/package'

module Lace extend self

  def active_packages
    installed_packages.select(&:is_active?)
  end

  def installed_packages
    Dir.glob(File.join(Lace.pkgs_folder, "**")).sort.map do |p|
      Package.new(Pathname.new(p).basename.to_s, false)
    end
  end

  def list
    if installed_packages.length > 0
      installed_packages.map do |package|
        puts "[#{Tty.green}#{package.is_active? ? "*" : " "}#{Tty.reset}] #{package.name}#{package.is_modified? ? " (has local changes)":""}"
      end
    else
      puts "There are no pkgs installed"
    end
  end

end
