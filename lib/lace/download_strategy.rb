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

  def initialize uri, desired_package_name=nil
    @desired_package_name = desired_package_name
    @uri = uri
    @target_folder = Lace.pkgs_folder/name
  end

  def uri
    @uri
  end

  # All download strategies are expected to implement these methods
  def fetch; end
  def stage; end
  def name
    @desired_package_name
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

  def repo_modified?
    @target_folder.cd do
      result = `git status --porcelain`
      result.split("\n").any? do |line|
        line =~ /^ M/
      end
    end
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
    @target_folder = Lace.pkgs_folder/name
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

class AbbrevGitDownloadStrategy < GitDownloadStrategy
  def initialize uri, desired_package_name=nil
    unless uri.end_with?(".git")
      uri = "#{uri}.git"
    end
    uri = "https://github.com/#{uri}"
    super uri, desired_package_name
  end
end


class DownloadStrategyDetector
  def self.detect(uri)
      detect_from_uri(uri)
  end

  def self.detect_from_uri(uri)
    is_git_dir = File.directory?(uri+"/.git")
    has_single_slash = uri.scan("/").count == 1
    via_ssh = uri.start_with?("git@")
    if File.directory?(uri) and not is_git_dir and not via_ssh
      return LocalFileStrategy
    elsif is_git_dir
      return GitDownloadStrategy
    elsif has_single_slash and not via_ssh
      return AbbrevGitDownloadStrategy
    end

    case uri
    when %r[^git\@] then GitDownloadStrategy
    when %r[^https?://.+\.git$] then GitDownloadStrategy
      # else CurlDownloadStrategy
    else
      raise "Cannot determine download startegy from #{uri}"
    end
  end
end
