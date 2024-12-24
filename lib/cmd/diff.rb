# frozen_string_literal: true

require 'lace/package'
require 'lace/exceptions'

module Lace
  module_function

  def diff
    package_name = ARGV.shift
    raise ResourceNotSpecified unless package_name

    package = Package.new(package_name, ARGV.first)
    diff = PackageUtils.diff package_name
    ohai 'The following files would be added [+] or removed [-]'
    diff.added.each do |f|
      puts "[+] #{f.basename} -> #{f.as_dotfile(Dir.home, package.path).to_path.gsub(Dir.home, '$HOME')}"
    end
    diff.removed.each do |f|
      puts "[-] #{f.basename} -> #{f.as_dotfile(Dir.home, package.path).to_path.gsub(Dir.home, '$HOME')}"
    end
  end
end
