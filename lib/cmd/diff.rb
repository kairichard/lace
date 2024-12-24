require 'lace/package'
require 'lace/exceptions'

module Lace extend self
  def diff
    package_name = ARGV.shift
    raise ResourceNotSpecified unless package_name
    package = Package.new(package_name, ARGV.first)
    diff = PackageUtils.diff package_name
    diff.added.each do |f|
      puts "[+] #{f.basename} -> #{f.as_dotfile(ENV["HOME"], package.path).to_path.gsub(ENV["HOME"], "$HOME")}"
    end
    diff.removed.each do |f|
      puts "[-] #{f.basename} -> #{f.as_dotfile(ENV["HOME"], package.path).to_path.gsub(ENV["HOME"], "$HOME")}"
    end
  end
end

