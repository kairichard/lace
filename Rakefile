require 'rubygems'
require 'cucumber'
require 'cucumber/rake/task'
require 'rspec/core/rake_task'

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "features --format pretty"
end


namespace :cucumber do

  Cucumber::Rake::Task.new(:wip, "Run the cucumber scenarios with the @wip tag") do |t|
    t.cucumber_opts = "features --tags @wip"
  end
end


RSpec::Core::RakeTask.new(:spec)
task :test => [:spec, :features]
