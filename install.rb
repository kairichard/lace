#!/usr/bin/env ruby
KOON_INSTALL_DIR = '/usr/local/dotkoon'
KOON_BIN_DIR = '/usr/local/bin'
CURRENT_DIR = File.dirname File.expand_path __FILE__
DOTTIES_DIR = File.join(ENV["HOME"], "dotkoon")

module Tty extend self
  def blue; bold 34; end
  def white; bold 39; end
  def red; underline 31; end
  def reset; escape 0; end
  def bold n; escape "1;#{n}" end
  def underline n; escape "4;#{n}" end
  def escape n; "\033[#{n}m" if STDOUT.tty? end
end

class Array
  def shell_s
    cp = dup
    first = cp.shift
    cp.map{ |arg| arg.gsub " ", "\\ " }.unshift(first) * " "
  end
end

def ohai *args
  puts "#{Tty.blue}==>#{Tty.white} #{args.shell_s}#{Tty.reset}"
end

def warn warning
  puts "#{Tty.red}Warning#{Tty.reset}: #{warning.chomp}"
end

def system *args
  abort "Failed during: #{args.shell_s}" unless Kernel.system *args
end

def sudo *args
  args = if args.length > 1
    args.unshift "/usr/bin/sudo"
  else
    "/usr/bin/sudo #{args.first}"
  end
  ohai *args
  system *args
end

def getc  # NOTE only tested on OS X
  system "/bin/stty raw -echo"
  if RUBY_VERSION >= '1.8.7'
    STDIN.getbyte
  else
    STDIN.getc
  end
ensure
  system "/bin/stty -raw echo"
end

def wait_for_user
  puts
  puts "Press ENTER to continue or any other key to abort"
  c = getc
  # we test for \r and \n because some stuff does \r instead
  abort unless c == 13 or c == 10
end

def git
  @git ||= if ENV['GIT'] and File.executable? ENV['GIT']
    ENV['GIT']
  elsif Kernel.system '/usr/bin/which -s git'
    'git'
  end

  return unless @git
  # Github only supports HTTPS fetches on 1.7.10 or later:
  # https://help.github.com/articles/https-cloning-errors
  `#{@git} --version` =~ /git version (\d\.\d+\.\d+)/
  return if $1.nil? or $1 < "1.7.10"

  @git
end

# The block form of Dir.chdir fails later if Dir.CWD doesn't exist which I
# guess is fair enough. Also sudo prints a warning message for no good reason
Dir.chdir "/usr"

####################################################################### script
abort <<-EOABORT unless Dir["#{KOON_INSTALL_DIR}/.git/*"].empty?
It appears Koon is already installed. If your intent is to reinstall you
should do the following before running this installer again:
    sudo rm -rf #{KOON_INSTALL_DIR}; sudo rm -f #{File.join(KOON_BIN_DIR, 'dotkoon')}
EOABORT

abort "Don't run this as root!" if Process.uid == 0

ohai "Downloading and installing koon..."
sudo("mkdir", "-p", KOON_INSTALL_DIR) if not File.directory? KOON_INSTALL_DIR
Dir.chdir KOON_INSTALL_DIR do
    # we do it in four steps to avoid merge errors when reinstalling
    if ARGV.include? "--localinstall"
      sudo git, "clone", CURRENT_DIR, "."
    else
      sudo git, "init", "-q"
      sudo git, "remote", "add", "origin", "https://github.com/kairichard/koon"

      args = git, "fetch", "origin", "master:refs/remotes/origin/master", "-n"
      args << "--depth=1" if ARGV.include? "--fast"
      sudo *args

      sudo git, "reset", "--hard", "origin/master"
    end
  sudo 'ln' , '-s' , File.join(KOON_INSTALL_DIR,'bin','dotkoon'), File.join(KOON_BIN_DIR, 'dotkoon')
end
ohai "Creating dotkoon directory in your HOME, because thats where we will store all available dotfiles for you"
Dir.mkdir DOTTIES_DIR
warn "#{KOON_BIN_DIR} is not in your PATH." unless ENV['PATH'].split(':').include? "#{KOON_BIN_DIR}"
ohai "Installation successful!"
