require 'aruba/cucumber'

require 'coveralls'
Coveralls.wear!

Before do
  @__old_lace_folder = ENV["LACE_FOLDER"]
  @__old_home = ENV["HOME"]

  @installed_cassias = "installed_cassias"
  @dirs = ["tmp/aruba"]

  ENV["LACE_FOLDER"] = File.expand_path('tmp/aruba/' + @installed_cassias)
  ENV["HOME"] = File.expand_path("tmp/aruba/HOME")

  set_environment_variable('LACE_FOLDER', File.expand_path('tmp/aruba/' + @installed_cassias))
  set_environment_variable('HOME', File.expand_path("tmp/aruba/HOME"))
  @aruba_timout_seconds = 5

  _mkdir ENV["HOME"]
  _mkdir ENV["LACE_FOLDER"]
end
