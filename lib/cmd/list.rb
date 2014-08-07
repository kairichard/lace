require 'lace/package'

module Lace extend self

  def linked_files
    home_dir = ENV["HOME"]
    Dir.foreach(home_dir).map do |filename|
      next if filename == '.' or filename == '..'
      File.readlink File.join(home_dir, filename) if File.symlink? File.join(home_dir, filename)
    end.compact.uniq
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
        puts "[#{Tty.green}#{package.is_active? ? "*" : " "}#{Tty.reset}] #{d}"
      end
    else
      puts "There are no pkgs installed"
    end
  end

end
