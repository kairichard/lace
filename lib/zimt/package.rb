require 'yaml'
require 'ostruct'
require 'set'

require 'zimt/download_strategy'
require 'zimt/exceptions'

class PackageUtils
  def self.is_package_any_flavor_active name
    @path = ZIMT_PKGS_FOLDER/name
    facts = Facts.new @path
    facts.flavors.any?{|f| Package.new(@name, f).is_active?}
  end

  def self.fetch uri, argv
    downloader = DownloadStrategyDetector.detect(uri).new(uri)
    if downloader.target_folder.exist?
      raise "Package already installed"
    end
    downloader.fetch
  end

  def self.remove package_name, argv
    ohai "Removing"
    package = Package.new package_name, false
    unless package.is_active?
      FileUtils.rm_rf package.path
      ohai "Successfully removed"
    else
      ofail "Cannot remove active kit, deactivate first"
    end
  end

  def self.install uri, argv
    downloader = DownloadStrategyDetector.detect(uri).new(uri)
    if downloader.target_folder.exist?
      raise "Package already installed"
    end
    downloader.fetch
    package = Package.new downloader.name, ARGV.first
    package.activate!
    package.after_install
  end

  def self.deactivate package_name, argv
    package = Package.new package_name, ARGV.shift
    raise NonActiveFlavorError.new unless package.is_active?
    package.deactivate!
  end

  def self.activate package_name, argv
    package = Package.new package_name, ARGV.shift
    raise AlreadyActiveError.new if Package.new(package_name, false).is_active?
    package.activate!
  end

  def self.update package_name, argv
    package = Package.new package_name, false
    raise OnlyGitReposCanBeUpdatedError.new unless package.is_git_repo?
    updater = GitUpdateStrategy.new package_name
    package.deactivate!
    updater.update
    package.read_facts!
    package.activate!
    package.after_update
  end
end

class Facts
  attr_reader :facts_file
  def initialize location
    @location = Pathname.new(location)
    @facts_file = @location/".zimt.yml"
    raise RuntimeError.new "No package file found in #@location" unless @facts_file.exist?
    @facts = YAML.load @facts_file.read
    @_facts = YAML.load @facts_file.read
  end

  def config_files
    if @_facts.nil? or @facts["config_files"].nil?
      []
    else
      @facts["config_files"].flatten.map do |file|
        @location + file
      end
    end
  end

  def has_flavors?
    @_facts && !@_facts["flavors"].nil?
  end

  def has_key? key
    @_facts && @_facts.has_key?(key)
  end

  def version
    @_facts["version"] if @_facts.key? "version"
  end

  def flavors
    if @_facts && @_facts.key?("flavors")
      @_facts["flavors"].keys
    else
      []
    end
  end

  def flavor! which_flavor
    raise RuntimeError.new "Flavor '#{which_flavor}' does not exist -> #{flavors.join(', ')} - use: zimt <command> <kit-uri> <flavor>" unless flavors.include? which_flavor
    @facts = @_facts["flavors"][which_flavor]
  end

  def unflavor!
    @facts = @_facts
  end

  def post hook_point
    if @_facts.nil? or !@facts.key? "post"
      []
    else
      post_hook = @facts["post"]
      (post_hook[hook_point.to_s] || []).flatten
    end
  end
end

class Package
  include GitCommands
  attr_reader :name, :facts, :path

  def after_install
    return if ARGV.nohooks?
     @path.cd do
       ENV["CURRENT_DOTTY"] = @path
       facts.post(:install).each do |cmd|
         safe_system cmd
       end
     end
  end

  def after_update
    return if ARGV.nohooks?
    @path.cd do
      ENV["CURRENT_DOTTY"] = @path
      facts.post(:update).each do |cmd|
        system cmd
      end
    end
  end

  def initialize name, flavor=nil
    require 'cmd/list'
    raise "Package #{name} is not installed" unless Zimt.installed_dotties.include? name
    @name = name
    @path = ZIMT_PKGS_FOLDER/name
    @flavor = flavor
    read_facts!
  end

  def is_git_repo?
    @target_folder = @path
    repo_valid?
  end

  def is_active?
    if @facts.has_flavors? && @flavor == false
      @facts.flavors.any?{|f| Package.new(@name, f).is_active?}
    else
      linked_files = Set.new Zimt.linked_files.map(&:to_s)
      config_files = Set.new @facts.config_files.map(&:to_s)
      config_files.subset? linked_files
    end
  end

  def read_facts!
    @facts = Facts.new @path
    if @facts.has_flavors? && @flavor.nil?
      raise RuntimeError.new FlavorArgumentMsg % @facts.flavors.join("\n- ")
    elsif @facts.has_flavors? && @flavor != false
      @facts.flavor! @flavor
    end
  end

  def deactivate!
    ohai "Deactivating"
    files = @facts.config_files
    home_dir = ENV["HOME"]
    files.each do |file|
      pn = Pathname.new file
      FileUtils.rm_f File.join(home_dir, "." + pn.basename)
    end
  end

  def activate!
    ohai "Activating"
    files = @facts.config_files
    home_dir = ENV["HOME"]
    files.each do |file|
      # if ends in erb -> generate it
      pn = Pathname.new file
      FileUtils.ln_s file, File.join(home_dir, "." + pn.basename)
    end
  end
end