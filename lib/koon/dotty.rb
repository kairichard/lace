require 'koon/download_strategy'

class Dotty

  attr_reader :name
  attr_writer :url

  def initialize url=nil, &block
    @url = url
    #instance_eval(&block) if block_given?
  end

  def downloader
    @downloader ||= download_strategy.new(url)
  end

  def download_strategy
    @download_strategy ||= DownloadStrategyDetector.detect(url)
  end

  def install(target=nil)
	downloader.fetch
  end

  def url val=nil
    return @url if val.nil?
    @url = val
  end
end
