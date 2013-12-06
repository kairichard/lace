require 'koon/download_strategy'
require 'yaml'
require 'ostruct'

class Facts
  def initialize location
    @location = Pathname.new(location)
    @facts_file = @location + "dotty.yml"
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
    !@facts["flavors"].nil?
  end

  def flavor! which_flavor
    @facts = @_facts[which_flavor]
  end

  def post hook_point
      @facts["post"][hook_point.to_s].flatten
  end
end

class Dotty

  attr_reader :name, :facts
  attr_writer :url

  def after_install
     downloader.target_folder.cd do
       ENV["CURRENT_DOTTY"] = downloader.target_folder
       facts.post(:install).each do |cmd|
         system cmd
       end
     end
  end

  def initialize url=nil, argv=nil
    @url = url
    @positional_args_from_cli = argv
  end

  def downloader
    @downloader ||= download_strategy.new(url)
  end

  def download_strategy
    @download_strategy ||= DownloadStrategyDetector.detect(url)
  end

  def install(target=nil)
    if is_installed? and is_active?
      read_facts!
      deactivate!
    end
    downloader.fetch
    read_facts!
    activate!
    after_install
  end

  def is_installed?
    downloader.target_folder.exist?
  end

  def is_active?
    # move parts of this into the koon lib itself
    home_dir = ENV["HOME"]
    installed_dotties = Dir.foreach(home_dir).map do |filename|
      File.readlink File.join(home_dir, filename) if File.symlink? File.join(home_dir, filename)
    end.compact.uniq.map do |path|
      Pathname.new File.dirname(path)
    end.uniq
    if installed_dotties.length == 1
      installed_dotties[0] == downloader.target_folder
    elsif installed_dotties.length == 0
      false
    else
      raise "there are more than one active dotty - which is not supported ATM"
    end
  end

  def read_facts!
    @facts = Facts.new downloader.target_folder
    if @facts.has_flavors?
      raise RuntimeError.new "Dotty comes with flavors pls specify as last arg" if @positional_args_from_cli.nil? || @positional_args_from_cli.empty?
      @facts.flavor! @positional_args_from_cli[-1]
    end
  end

  def deactivate!
    ohai "Deactivting"
    files = @facts.config_files
    home_dir = ENV["HOME"]
    files.each do |file|
      pn = Pathname.new file
      FileUtils.rm_f File.join(home_dir, "." + pn.basename)
    end
  end

  def activate!
    ohai "Activting"
    files = @facts.config_files
    home_dir = ENV["HOME"]
    files.each do |file|
      # if ends in erb -> generate it
      pn = Pathname.new file
      FileUtils.ln_s file, File.join(home_dir, "." + pn.basename)
    end
  end

  def url val=nil
    return @url if val.nil?
    @url = val
  end
end
