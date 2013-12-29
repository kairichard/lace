require 'yaml'
require 'ostruct'
require 'set'

require 'koon/download_strategy'
require 'koon/exceptions'

class DottyUtils
  def self.is_dotty_any_flavor_active name
    @path = KOON_DOTTIES/name
    facts = Facts.new @path
    facts.flavors.any?{|f| Dotty.new(@name, f).is_active?}
  end

  def self.fetch uri, argv
    downloader = DownloadStrategyDetector.detect(uri).new(uri)
    if downloader.target_folder.exist?
      raise "Dotty already installed"
    end
    downloader.fetch
  end

  def self.remove dotty_name, argv
    ohai "Removing"
    dotty = Dotty.new dotty_name, false
    unless dotty.is_active?
      FileUtils.rm_rf dotty.path
      ohai "Successfully removed"
    else
      ofail "Cannot remove active kit, deactivate first"
    end
  end

  def self.install uri, argv
    downloader = DownloadStrategyDetector.detect(uri).new(uri)
    if downloader.target_folder.exist?
      raise "Dotty already installed"
    end
    downloader.fetch
    dotty = Dotty.new downloader.name, ARGV.first
    dotty.activate!
    dotty.after_install
  end

  def self.deactivate dotty_name, argv
    dotty = Dotty.new dotty_name, ARGV.shift
    raise NonActiveFlavorError.new unless dotty.is_active?
    dotty.deactivate!
  end

  def self.activate dotty_name, argv
    dotty = Dotty.new dotty_name, ARGV.shift
    raise AlreadyActiveError.new if Dotty.new(dotty_name, false).is_active?
    dotty.activate!
  end

  def self.update dotty_name, argv
    dotty = Dotty.new dotty_name, false
    raise OnlyGitReposCanBeUpdatedError.new unless dotty.is_git_repo?
    updater = GitUpdateStrategy.new dotty_name
    dotty.deactivate!
    updater.update
    dotty.read_facts!
    dotty.activate!
    dotty.after_update
  end
end

class Facts
  def initialize location
    @location = Pathname.new(location)
    @facts_file = @location/"dotty.yml"
    raise RuntimeError.new "No dotty file found in #@location" unless @facts_file.exist?
    @facts = YAML.load @facts_file.read
    @_facts = YAML.load @facts_file.read
  end

  def config_files
    @facts["config_files"].flatten.map do |file|
      @location + file
    end
  end

  def has_flavors?
    !@_facts["flavors"].nil?
  end

  def flavors
    @_facts["flavors"].keys
  end

  def flavor! which_flavor
    raise RuntimeError.new "Flavor '#{which_flavor}' does not exist -> #{flavors.join(', ')} - use: zimt <command> <kit-uri> <flavor>" unless flavors.include? which_flavor
    @facts = @_facts["flavors"][which_flavor]
  end

  def post hook_point
    if !@facts.key? "post"
      []
    else
      post_hook = @facts["post"]
      (post_hook[hook_point.to_s] || []).flatten
    end
  end
end

class Dotty
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
    raise "Dotty #{name} is not installed" unless Koon.installed_dotties.include? name
    @name = name
    @path = KOON_DOTTIES/name
    @flavor = flavor
    read_facts!
  end

  def is_git_repo?
    @target_folder = @path
    repo_valid?
  end

  def is_active?
    if @facts.has_flavors? && @flavor == false
      @facts.flavors.any?{|f| Dotty.new(@name, f).is_active?}
    else
      linked_files = Set.new Koon.linked_files.map(&:to_s)
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
