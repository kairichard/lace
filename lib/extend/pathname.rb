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

require 'pathname'
# we enhance pathname to make our code more readable
class Pathname

  def cp dst
    if file?
      FileUtils.cp to_s, dst
    else
      FileUtils.cp_r to_s, dst
    end
    return dst
  end

  # for filetypes we support, basename without extension
  def stem
    File.basename((path = to_s), extname(path))
  end

  # I don't trust the children.length == 0 check particularly, not to mention
  # it is slow to enumerate the whole directory just to see if it is empty,
  # instead rely on good ol' libc and the filesystem
  def rmdir_if_possible
    rmdir
    true
  rescue Errno::ENOTEMPTY
    if (ds_store = self+'.DS_Store').exist? && children.length == 1
      ds_store.unlink
      retry
    else
      false
    end
  rescue Errno::EACCES, Errno::ENOENT
    false
  end

  def chmod_R perms
    require 'fileutils'
    FileUtils.chmod_R perms, to_s
  end

  if '1.9' <= RUBY_VERSION
    alias_method :to_str, :to_s
  end

  def cd
    Dir.chdir(self){ yield }
  end

  def subdirs
    children.select{ |child| child.directory? }
  end

  def resolved_path
    self.symlink? ? dirname+readlink : self
  end

  def resolved_path_exists?
    link = readlink
  rescue ArgumentError
    # The link target contains NUL bytes
    false
  else
    (dirname+link).exist?
  end

  def / that
    join that.to_s
  end

  def as_backup
    Pathname.new File.join(dirname, "#{basename}.lace.bak")
  end

  def as_dotfile base_folder
    Pathname.new File.join(base_folder, ".#{basename}")
  end

end
