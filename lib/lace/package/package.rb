require 'set'

require 'lace/download_strategy'

class Package
  include GitCommands
  attr_reader :name, :facts, :path

  def initialize name, flavor=nil
    require 'cmd/list'
    raise PackageNotInstalled.new(name) unless Lace.installed_packages.include?(name)
    @name = name
    @path = Lace.pkgs_folder/name
    @flavor = flavor
    read_facts!
  end

  def setup
    return if ARGV.nohooks?
    ENV['LACEPKG_PATH'] = @path
     @path.cd do
       facts.setup_files.each do |cmd|
         safe_system cmd
       end
     end
  end

  def after_update
    return if ARGV.nohooks?
    @path.cd do
      facts.post(:update).each do |cmd|
        system cmd
      end
    end
  end

  def is_git_repo?
    @target_folder = @path
    repo_valid?
  end

  def is_modified?
    return false unless is_git_repo?
    @target_folder = @path
    repo_modified?
  end

  def is_active?
    if @facts.has_flavors? && @flavor == false
      @facts.flavors.any?{|f| Package.new(@name, f).is_active?}
    else
      linked_files = Set.new Lace.linked_files.map(&:to_s)
      config_files = Set.new @facts.config_files.map(&:to_s)
      config_files.subset? linked_files
    end
  end

  def read_facts!
    @facts = PackageFacts.new @path
    @facts.flavor_with @flavor
  end

  def deactivate!
    files = @facts.config_files
    home_dir = ENV["HOME"]
    files.each do |file|
      file = Pathname.new(file)
      dotfile = file.as_dotfile(home_dir, @path)
      FileUtils.rm_f dotfile if dotfile.exist? && dotfile.readlink == file
    end
  end

  def activate!
    files = @facts.config_files
    files.each do |file|
      link_file file
    end
  end

  def link_file file
    home_dir = ENV["HOME"]
    # if ends in erb -> generate it
    src = file
    dest = src.as_dotfile(home_dir, @path)
    if dest.exist? && dest.directory? && ARGV.force?
      FileUtils.mv dest, dest.as_backup
    end
    link_file_or_directory src, dest
  end

  def link_file_or_directory(src, dest)
    if !dest.dirname.exist?
      dest.dirname.mkpath
    end
    FileUtils.ln_s src, dest, :force => ARGV.force?
  end
end
