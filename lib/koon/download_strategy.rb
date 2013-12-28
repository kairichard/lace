require "fileutils"

class AbstractDownloadStrategy
  attr_reader :name, :resource, :target_folder

  def initialize uri
    @uri = uri
    @target_folder = KOON_DOTTIES/name
  end

  # All download strategies are expected to implement these methods
  def fetch; end
  def stage; end
  def name
    ARGV.value "name"
  end
end


class LocalFileStrategy < AbstractDownloadStrategy
  def fetch
    ohai "Fetching #@uri into #@target_folder"
    FileUtils.cp_r @uri, @target_folder
    @target_folder
  end

  def name
    super || File.basename(@uri)
  end
end


module GitCommands
  def update_repo
    safe_system 'git', 'fetch', 'origin'
  end

  def reset
    safe_system 'git', "reset" , "--hard", "origin/HEAD"
  end

  def git_dir
    @target_folder.join(".git")
  end

  def repo_valid?
    quiet_system "git", "--git-dir", git_dir, "status", "-s"
  end

  def submodules?
    @target_folder.join(".gitmodules").exist?
  end

  def clone_args
    args = %w{clone}
    args << @uri << @target_folder
  end

  def clone_repo
    safe_system 'git', *clone_args
    @target_folder.cd { update_submodules } if submodules?
  end

  def update_submodules
    safe_system 'git', 'submodule', 'update', '--init'
  end
end


class GitUpdateStrategy
  include GitCommands

  def initialize name
    @target_folder = KOON_DOTTIES/name
  end

  def update
    if repo_valid?
      puts "Updating #@target_folder"
      @target_folder.cd do
        update_repo
        reset
        update_submodules if submodules?
      end
    else
      puts "Removing invalid .git repo"
      FileUtils.rm_rf @target_folder
      clone_repo
    end
  end
end


class GitDownloadStrategy < AbstractDownloadStrategy
  include GitCommands

  def fetch
    ohai "Cloning #@uri"

    if @target_folder.exist? && repo_valid?
      puts "Updating #@target_folder"
      @target_folder.cd do
        update_repo
        reset
        update_submodules if submodules?
      end
    elsif @target_folder.exist?
      puts "Removing invalid .git repo"
      FileUtils.rm_rf @target_folder
      clone_repo
    else
      clone_repo
    end
    @target_folder
  end

  def name
    if super
      super
    elsif @uri.include? "github.com"
       @uri.split("/")[-2]
    elsif File.directory? @uri
        File.basename(@uri)
    else
      raise "Cannot determine a proper name with #@uri"
    end
  end

end


class DownloadStrategyDetector
  def self.detect(uri, strategy=nil)
    if strategy.nil?
      detect_from_uri(uri)
    elsif Symbol === strategy
      detect_from_symbol(strategy)
    else
      raise TypeError,
        "Unknown download strategy specification #{strategy.inspect}"
    end
  end

  def self.detect_from_uri(uri)
    if File.directory?(uri) && !File.directory?(uri+"/.git")
      return LocalFileStrategy
    elsif File.directory?(uri+"/.git")
      return GitDownloadStrategy
    end

    case uri
      when %r[^git://] then GitDownloadStrategy
      when %r[^https?://.+\.git$] then GitDownloadStrategy
      # else CurlDownloadStrategy
    else
      raise "Cannot determine download startegy from #{uri}"
    end
  end

  def self.detect_from_symbol(symbol)
    case symbol
    when :git then GitDownloadStrategy
    when :local_file then LocalFileStrategy
    else
      raise "Unknown download strategy #{strategy} was requested."
    end
  end
end
