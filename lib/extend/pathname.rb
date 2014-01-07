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

  # extended to support common double extensions
  alias extname_old extname
  def extname(path=to_s)
    BOTTLE_EXTNAME_RX.match(path)
    return $1 if $1
    /(\.(tar|cpio|pax)\.(gz|bz2|xz|Z))$/.match(path)
    return $1 if $1
    return File.extname(path)
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

  def abv
    out=''
    n=`find #{to_s} -type f ! -name .DS_Store | wc -l`.to_i
    out<<"#{n} files, " if n > 1
    out<<`/usr/bin/du -hs #{to_s} | cut -d"\t" -f1`.strip
  end

  def compression_type
    # Don't treat jars or wars as compressed
    return nil if self.extname == '.jar'
    return nil if self.extname == '.war'

    # OS X installer package
    return :pkg if self.extname == '.pkg'

    # If the filename ends with .gz not preceded by .tar
    # then we want to gunzip but not tar
    return :gzip_only if self.extname == '.gz'

    # Get enough of the file to detect common file types
    # POSIX tar magic has a 257 byte offset
    # magic numbers stolen from /usr/share/file/magic/
    case open('rb') { |f| f.read(262) }
    when /^PK\003\004/n         then :zip
    when /^\037\213/n           then :gzip
    when /^BZh/n                then :bzip2
    when /^\037\235/n           then :compress
    when /^.{257}ustar/n        then :tar
    when /^\xFD7zXZ\x00/n       then :xz
    when /^Rar!/n               then :rar
    when /^7z\xBC\xAF\x27\x1C/n then :p7zip
    else
      # This code so that bad-tarballs and zips produce good error messages
      # when they don't unarchive properly.
      case extname
      when ".tar.gz", ".tgz", ".tar.bz2", ".tbz" then :tar
      when ".zip" then :zip
      end
    end
  end

  def text_executable?
    %r[^#!\s*\S+] === open('r') { |f| f.read(1024) }
  end

  def incremental_hash(hasher)
    incr_hash = hasher.new
    buf = ""
    open('rb') { |f| incr_hash << buf while f.read(1024, buf) }
    incr_hash.hexdigest
  end

  def sha1
    require 'digest/sha1'
    incremental_hash(Digest::SHA1)
  end

  def sha256
    require 'digest/sha2'
    incremental_hash(Digest::SHA2)
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

  def ensure_writable
    saved_perms = nil
    unless writable_real?
      saved_perms = stat.mode
      chmod 0644
    end
    yield
  ensure
    chmod saved_perms if saved_perms
  end

  # Writes an exec script in this folder for each target pathname
  def write_exec_script *targets
    targets.flatten!
    if targets.empty?
      opoo "tried to write exec scripts to #{self} for an empty list of targets"
    end
    targets.each do |target|
      target = Pathname.new(target) # allow pathnames or strings
      (self+target.basename()).write <<-EOS.undent
      #!/bin/bash
      exec "#{target}" "$@"
      EOS
    end
  end

  # We redefine these private methods in order to add the /o modifier to
  # the Regexp literals, which forces string interpolation to happen only
  # once instead of each time the method is called. This is fixed in 1.9+.
  if RUBY_VERSION <= "1.8.7"
    alias_method :old_chop_basename, :chop_basename
    def chop_basename(path)
      base = File.basename(path)
      if /\A#{Pathname::SEPARATOR_PAT}?\z/o =~ base
        return nil
      else
        return path[0, path.rindex(base)], base
      end
    end
    private :chop_basename

    alias_method :old_prepend_prefix, :prepend_prefix
    def prepend_prefix(prefix, relpath)
      if relpath.empty?
        File.dirname(prefix)
      elsif /#{SEPARATOR_PAT}/o =~ prefix
        prefix = File.dirname(prefix)
        prefix = File.join(prefix, "") if File.basename(prefix + 'a') != 'a'
        prefix + relpath
      else
        prefix + relpath
      end
    end
    private :prepend_prefix
  end
end
