require 'aruba/cucumber'

require 'coveralls'
Coveralls.wear!

Before do
  @__old_lace_folder = ENV["LACE_FOLDER"]
  @__old_home = ENV["HOME"]

  @installed_cassias = "installed_cassias"

  ENV["LACE_FOLDER"] = File.expand_path('tmp/aruba/' + @installed_cassias)
  ENV["HOME"] = File.expand_path("tmp/aruba/HOME")

  in_current_dir do
    _mkdir ENV["HOME"]
    _mkdir ENV["LACE_FOLDER"]
  end
end
