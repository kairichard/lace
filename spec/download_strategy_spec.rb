require 'lace'
require 'lace/download_strategy'
require "extend/pathname"

describe "DownloadStrategyDetector" do
  it "detects a strategy for github if package name is the format of user/repo" do
    uri = 'someuser/demorepository'
    strategy = DownloadStrategyDetector.detect(uri)
    expect(strategy).to be AbbrevGitDownloadStrategy
  end

describe "AbbrevGitDownloadStrategy" do

  it "builds the url to github correctly without extension" do
    uri = 'someuser/demorepository'
    strategy = AbbrevGitDownloadStrategy.new(uri)
    expect(strategy.uri).to eq "https://github.com/someuser/demorepository.git"
  end

  it "builds the url to github correctly with extension" do
    uri = 'someuser/demorepository.git'
    strategy = AbbrevGitDownloadStrategy.new(uri)
    expect(strategy.uri).to eq "https://github.com/someuser/demorepository.git"
  end
end
