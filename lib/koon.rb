std_trap = trap("INT") { exit! 130 } # no backtrace thanks
KOON_FILE = ENV["KOON_FILE"]

require 'pathname'
KOON_LIB_PATH = Pathname.new(__FILE__).realpath.dirname.parent.join("lib").to_s
puts KOON_LIB_PATH
puts "hello"
