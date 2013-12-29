require 'aruba/cucumber'

Before do
  @__old_zimt_folder = ENV["ZIMT_FOLDER"]
  @__old_home = ENV["HOME"]
  @installed_cassias = "installed_cassias"

  ENV["ZIMT_FOLDER"] = File.expand_path('tmp/aruba/' + @installed_cassias)
  ENV["HOME"] = File.expand_path("tmp/aruba/HOME")

  in_current_dir do
    _mkdir ENV["HOME"]
    _mkdir ENV["ZIMT_FOLDER"]
  end
end
