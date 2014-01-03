$:.unshift File.expand_path("../lib", __FILE__)
require "zimt/version"
Gem::Specification.new do |s|
  s.name        = 'zimt'
  s.version     = Zimt::VERSION
  s.summary     = "Manage your .dotfiles"
  s.description = "This is a simple/unfinished tool which i use to manage my dotfiles on all the different machines"
  s.authors     = ["Kai Richard Koenig"]
  s.email       = 'kai@kairichardkoenig.de'
  s.files       = Dir.glob("lib/**/*.rb")
  s.homepage    = 'https://github.com/kairichard/zimt'
  s.bindir = 'bin'
  s.executables << "zimt"
  s.license = 'MIT'
  s.required_ruby_version = '>= 1.8.6'
end
