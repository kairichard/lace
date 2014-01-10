require 'pathname'
# borrowed from brew.sh
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

  def as_dotfile base_folder
    Pathname.new File.join(base_folder, ".#{basename}")
  end

end
