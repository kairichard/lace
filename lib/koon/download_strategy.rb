require "fileutils"

class AbstractDownloadStrategy
  attr_reader :name, :resource

  def initialize url
    @url  = url
    @clone = KOON_DOTTIES/name
  end

  # All download strategies are expected to implement these methods
  def fetch; end
  def stage; end
  def name; end
end

class LocalFileStrategy < AbstractDownloadStrategy
  def fetch
    ohai "Installing form local file #@url"
    if @clone.exist?
			ohai "Removing already installed dottie #@clone"
			FileUtils.rm_rf @clone
		else
			ohai "Installing #@url into #@clone"
			FileUtils.cp_r @url, @clone
	  end
  end
  def name
		File.basename @url
  end
end

class GitDownloadStrategy < AbstractDownloadStrategy
  def fetch
    ohai "Cloning #@url"

    if @clone.exist? && repo_valid?
      puts "Updating #@clone"
      @clone.cd do
        update_repo
        reset
        update_submodules if submodules?
      end
    elsif @clone.exist?
      puts "Removing invalid .git repo"
      FileUtils.rm_rf @clone
      clone_repo
    else
      clone_repo
    end
  end

  def name
    if @url.include? "github.com"
	@url.split("/")[-2]
    else 
      raise "Cannot determine a proper name with #@url"
    end
  end

  private
  def update_repo
    quiet_system 'git', 'fetch', 'origin'
  end

  def reset
    quiet_system 'git', "reset" , "--hard", "origin/HEAD"
  end

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
    if File.directory? url  then return LocalFileStrategy end
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
    when :local_file then LocalFileStrategy
    #when :curl then CurlDownloadStrategy
    else
      raise "Unknown download strategy #{strategy} was requested."
    end
  end
end
