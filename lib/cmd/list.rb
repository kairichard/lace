require 'lace/package'

module Lace extend self

  def linked_files
    home_dir = Pathname.new ENV["HOME"]
    find_links home_dir
  end

  def find_links dir
    dir.children.map do |path|
      if path.directory? && !path.symlink?
        find_links path
      else
        File.readlink path if path.symlink?
      end
    end.flatten.compact.uniq
  end

  def active_packages
    linked_files.map do |path|
      Pathname.new(File.dirname(path)).basename.to_s
    end.uniq
  end

  def installed_packages
    Dir.glob(File.join(Lace.pkgs_folder, "**")).sort.map do |p|
      Pathname.new(p).basename.to_s
    end
  end

  def list
    if installed_packages.length > 0
      installed_packages.map do |d|
        package = Package.new(d, false)
        puts "[#{Tty.green}#{package.is_active? ? "*" : " "}#{Tty.reset}] #{d}#{package.is_modified? ? " (has local changes)":""}"
      end
    else
      puts "There are no pkgs installed"
    end
  end

end
