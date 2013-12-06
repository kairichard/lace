std_trap = trap("INT") { exit! 130 } # no backtrace thanks
KOON_FILE = ENV["KOON_FILE"]

require 'pathname'
KOON_LIB_PATH = Pathname.new(__FILE__).realpath.dirname.parent.join("lib").to_s

$:.unshift(KOON_LIB_PATH)
$:.unshift(KOON_LIB_PATH + "/vendor")

require "koon/utils"
require "koon/exceptions"
require "extend/ARGV"
require "extend/pathname"
require "debugger"
KOON_DOTTIES = Pathname.new(ENV["HOME"]).join("dotkoon")

module Koon extend self
  attr_accessor :failed
  alias_method :failed?, :failed
end

ARGV.extend(KoonArgvExtension)

case ARGV.first when '-h', '--help', '--usage', '-?', 'help', nil
  require 'cmd/help'
  puts Koon.help_s
  exit ARGV.first ? 0 : 1
when '--version'
  puts KOON_VERSION
  exit 0
when '-v'
  puts "dotkoon #{KOON_VERSION}"
  # Shift the -v to the end of the parameter list
  ARGV << ARGV.shift
  # If no other arguments, just quit here.
  exit 0 if ARGV.length == 1
end

begin

  trap("INT", std_trap) # restore default CTRL-C handler
  if Process.uid.zero?
    raise "Refusing to run as sudo"
  end
  aliases = {'ls' => 'list',
             'rm' => 'remove',
             'configure' => 'diy',
             }

  cmd = ARGV.shift
  cmd = aliases[cmd] if aliases[cmd]

  if require "cmd/" + cmd
    Koon.send cmd.to_s.gsub('-', '_').downcase
  else
    onoe "Unknown command: #{cmd}"
    exit 1
  end

rescue ResourceNotSpecified
  abort "This command requires a resource argument"
rescue UsageError
  onoe "Invalid usage"
  abort ARGV.usage
rescue SystemExit
  puts "Kernel.exit" if ARGV.verbose?
  raise
rescue Interrupt => e
  puts # seemingly a newline is typical
  exit 130
rescue RuntimeError, SystemCallError => e
  raise if e.message.empty?
  onoe e
  puts e.backtrace if false
  exit 1
rescue Exception => e
  onoe e
  puts "#{Tty.white}Please report this bug:"
  puts e.backtrace
  exit 1
else
  exit 1 if Koon.failed?
end
