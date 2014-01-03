require 'koon/dotty'

module Zimt extend self

  def linked_files
    home_dir = ENV["HOME"]
    Dir.foreach(home_dir).map do |filename|
      next if filename == '.' or filename == '..'
      File.readlink File.join(home_dir, filename) if File.symlink? File.join(home_dir, filename)
    end.compact.uniq
  end

  def active_dotties
    linked_files.map do |path|
      Pathname.new File.dirname(path)
    end.uniq
  end

  def installed_dotties
    Dir.glob(File.join(KOON_DOTTIES, "**")).map do |p|
      Pathname.new(p).basename.to_s
    end
  end

  def list
    if installed_dotties.length > 0
      installed_dotties.map do |d|
        dotty = Dotty.new d, false
        puts "- [#{Tty.green}#{dotty.is_active? ? "*" : " "}#{Tty.reset}] #{d}"
      end
    else
      puts "There are no kits installed"
    end
  end

end
