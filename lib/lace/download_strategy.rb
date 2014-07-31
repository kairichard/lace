#Copyright 2009-2014 Max Howell and other contributors.
#
#Redistribution and use in source and binary forms, with or without
#modification, are permitted provided that the following conditions
#are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
#THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
#IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
#OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
#IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
#INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
#NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
#DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
#THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
#THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require "fileutils"

class AbstractDownloadStrategy
  attr_reader :name, :resource, :target_folder

  def initialize uri
    @uri = uri
    @target_folder = LACE_PKGS_FOLDER/name
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
    FileUtils.cp_r @uri, @target_folder, :preserve => true
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
    @target_folder = LACE_PKGS_FOLDER/name
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
