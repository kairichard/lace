require 'lace'
require 'lace/download_strategy'
require "extend/pathname"

describe "DownloadStrategyDetector" do
  it "detects a strategy for github if package name is the format of user/repo" do
    uri = 'someuser/demorepository'
    strategy = DownloadStrategyDetector.detect(uri)
    expect(strategy).to be AbbrevGitDownloadStrategy
  end
end
