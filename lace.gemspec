$:.unshift File.expand_path("../lib", __FILE__)
require "lace/version"
Gem::Specification.new do |s|
  s.name        = 'lace'
  s.version     = Lace::VERSION
  s.summary     = "Manage your .dotfiles"
  s.description = "Lace lets you manage your dotfiles when using them on multiple machines"
  s.authors     = ["Kai Richard Koenig"]
  s.email       = 'kai.richard.koenig@gmail.com'
  s.files       = Dir.glob("lib/**/*.rb")
  s.homepage    = 'https://github.com/kairichard/lace'
  s.bindir = 'bin'
  s.executables << "lace"
  s.license = 'MIT'
  s.required_ruby_version = '>= 3.0.0'
end
