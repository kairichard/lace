require 'koon/dotty'

module Koon extend self
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
