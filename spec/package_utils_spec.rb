# frozen_string_literal: true

require 'lace'
require 'lace/download_strategy'
require 'lace/package'

describe 'PackageUtils' do
  it 'fetches and abbriviated github-url' do
    expect_any_instance_of(GitDownloadStrategy).to receive(:fetch) {
      true
    }
    PackageUtils.fetch('uff/somewhere', nil)
  end
end
