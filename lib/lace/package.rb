require 'set'
require 'yaml'
require 'ostruct'
require 'erb'

require 'lace/download_strategy'
require 'lace/exceptions'

class PackageUtils

  def self.fetch uri
    downloader = DownloadStrategyDetector.detect(uri).new(uri)
    raise PackageAlreadyInstalled.new if downloader.target_folder.exist?
    downloader.fetch
    return downloader.name, downloader.target_folder
  end

  def self.remove package_name
    package = Package.new package_name, false
    raise CannotRemoveActivePackage.new if package.is_active?
    ohai "Removing"
    FileUtils.rm_rf package.path
  end

  def self.setup package_name
    begin
      package = Package.new package_name, ARGV.first
      package.activate!
      package.setup
    rescue FlavorError => e
      onoe e.message
      onoe "Package remains installed but was not activated"
    end
  end

  def self.deactivate package_name
    package = Package.new package_name, ARGV.first
    raise NonActiveFlavorError.new unless package.is_active? || ARGV.force?
    ohai "Deactivating"
    package.deactivate!
  end

  def self.activate package_name
    package = Package.new package_name, ARGV.first
    raise AlreadyActiveError.new if Package.new(package_name, false).is_active?
    ohai "Activating"
    package.activate!
  end

  def self.update package_name
    package = Package.new package_name, false
    raise OnlyGitReposCanBeUpdatedError.new unless package.is_git_repo?
    updater = GitUpdateStrategy.new package_name
    was_active_before_update = package.is_active?
    self.deactivate(package_name) if was_active_before_update
    ohai "Updating"
    updater.update
    self.activate(package_name) if was_active_before_update
    package = Package.new package_name, false
    package.after_update
  end
end

class Facts
  attr_reader :facts_file

  def inspect
    "#<Facts:#{@package_path}>"
  end

  def initialize package_path
    @package_path = Pathname.new(package_path)
    @facts_file = @package_path/".lace.yml"
    raise PackageFactsNotFound.new(@package_path) unless @facts_file.exist?
    @facts = facts_file_to_hash
    @unflavorable_facts = facts_file_to_hash
  end

  def config_files
    if @unflavorable_facts.nil? or @facts["config_files"].nil?
      []
    else
      @facts["config_files"].flatten.map do |file|
        @package_path + file
      end
    end
  end

  def has_flavors?
    @unflavorable_facts && !@unflavorable_facts["flavors"].nil?
  end

  def has_key? key
    @unflavorable_facts && @unflavorable_facts.has_key?(key)
  end

  def version
    @unflavorable_facts["version"] if @unflavorable_facts.key? "version"
  end

  def setup_files
    @facts["setup"].flatten rescue []
  end

  def homepage
    @unflavorable_facts["homepage"] if @unflavorable_facts.key? "homepage"
  end

  def flavors
    if @unflavorable_facts && @unflavorable_facts.key?("flavors")
      @unflavorable_facts["flavors"].keys.sort
    else
      []
    end
  end

  def flavor! which_flavor
    raise PackageFlavorDoesNotExist.new(which_flavor, flavors) unless flavors.include? which_flavor
    @facts = @unflavorable_facts["flavors"][which_flavor]
  end

  def unflavor!
    @facts = @unflavorable_facts
  end

  def post hook_point
    if @unflavorable_facts.nil? or !@facts.key? "post"
      []
    else
      post_hook = @facts["post"]
      (post_hook[hook_point.to_s] || []).flatten
    end
  end

  protected
  def facts_file_to_hash
    begin
      rendered_manifest = ERB.new(@facts_file.read, nil, '-').result(binding)
    rescue Exception => e
      raise ManifestErbError.new(self, e)
    end
    value = YAML.load rendered_manifest
    if value.is_a?(String) && value == "---"
      return Hash.new
    else
      value
    end
  end
end

class Package
  include GitCommands
  attr_reader :name, :facts, :path

  def initialize name, flavor=nil
    require 'cmd/list'
    raise PackageNotInstalled.new(name) unless Lace.installed_packages.include?(name)
    @name = name
    @path = LACE_PKGS_FOLDER/name
    @flavor = flavor
    read_facts!
  end

  def setup
    return if ARGV.nohooks?
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
    # todo simplify
    @facts = Facts.new @path
    if @facts.has_flavors? && @flavor.nil?
      raise FlavorArgumentRequired.new @facts.flavors
    elsif @facts.has_flavors? && @flavor != false
      @facts.flavor! @flavor
    end
  end

  def deactivate!
    files = @facts.config_files
    home_dir = ENV["HOME"]
    files.each do |file|
      file = Pathname.new(file)
      dotfile = file.as_dotfile(home_dir)
      FileUtils.rm_f dotfile if dotfile.exist? && dotfile.readlink == file
    end
  end

  def activate!
    files = @facts.config_files
    home_dir = ENV["HOME"]
    files.each do |file|
      # if ends in erb -> generate it
      FileUtils.ln_s file, Pathname.new(file).as_dotfile(home_dir), :force => ARGV.force?
    end
  end
end
