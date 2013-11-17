class AbstractDownloadStrategy
  attr_reader :name, :resource

  def initialize url
    @url  = url
  end

  # All download strategies are expected to implement these methods
  def fetch; end
  def stage; end
end

class GitDownloadStrategy < AbstractDownloadStrategy
  def fetch
    ohai "Cloning #@url"
    clone_repo
  end

  def stage
  end

  private

  def git_dir
    @clone.join(".git")
  end

  def repo_valid?
    quiet_system "git", "--git-dir", git_dir, "status", "-s"
  end

  def submodules?
    @clone.join(".gitmodules").exist?
  end

  def clone_args
    args = %w{clone}
    args << @url << @clone
  end

  def clone_repo
    safe_system 'git', *clone_args
    @clone.cd { update_submodules } if submodules?
  end

  def update_submodules
    safe_system 'git', 'submodule', 'update', '--init'
  end
end


class DownloadStrategyDetector
  def self.detect(url, strategy=nil)
    if strategy.nil?
      detect_from_url(url)
    elsif Symbol === strategy
      detect_from_symbol(strategy)
    else
      raise TypeError,
        "Unknown download strategy specification #{strategy.inspect}"
    end
  end

  def self.detect_from_url(url)
    case url
    when %r[^git://] then GitDownloadStrategy
    when %r[^https?://.+\.git$] then GitDownloadStrategy
    # else CurlDownloadStrategy
    else
      raise "Cannot determine download startegy from #{url}"
    end
  end

  def self.detect_from_symbol(symbol)
    case symbol
    when :git then GitDownloadStrategy
    #when :curl then CurlDownloadStrategy
    else
      raise "Unknown download strategy #{strategy} was requested."
    end
  end
end
