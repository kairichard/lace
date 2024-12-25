# frozen_string_literal: true

require 'lace'
require 'lace/download_strategy'
require 'extend/pathname'
require 'fileutils'

describe 'DownloadStrategyDetector' do
  it 'detects a strategy for github if package name is the format of user/repo' do
    uri = 'someuser/repo'
    strategy = DownloadStrategyDetector.detect(uri)
    expect(strategy).to be GitHubDownloadStrategy
  end

  it 'detects a strategy for localfile if file actually exists' do
    uri = 'someuser/file'
    FileUtils.mkdir_p uri
    strategy = DownloadStrategyDetector.detect(uri)
    expect(strategy).to be LocalFileStrategy
    FileUtils.rm_rf uri
  end

  it 'detects a strategy for localfile if file actually exists without extension' do
    uri = 'someuser/repo'
    FileUtils.mkdir_p uri
    strategy = DownloadStrategyDetector.detect("#{uri}.git")
    expect(strategy).to be GitHubDownloadStrategy
    FileUtils.rm_rf uri
  end

  it 'detects a strategy for a git repo using the ssh syntax' do
    uri = 'git@github.com:someuser/repo.git'
    strategy = DownloadStrategyDetector.detect(uri)
    expect(strategy).to be GitDownloadStrategy
  end
end

describe 'GitHubDownloadStrategy' do
  it 'builds the url to github correctly without extension' do
    uri = 'someuser/demorepository'
    strategy = GitHubDownloadStrategy.new(uri)
    expect(strategy.uri).to eq 'https://github.com/someuser/demorepository.git'
  end

  it 'builds the url to github correctly with extension' do
    uri = 'someuser/demorepository.git'
    strategy = GitHubDownloadStrategy.new(uri)
    expect(strategy.uri).to eq 'https://github.com/someuser/demorepository.git'
  end
end

describe 'GitDownloadStrategy' do
  it 'builds the url to github correctly without extension' do
    uri = 'git@github.com:/some/repo.git'
    strategy = GitDownloadStrategy.new(uri)
    expect(strategy.uri).to eq 'git@github.com:/some/repo.git'
    expect(strategy.name).to eq 'some'
  end
end
