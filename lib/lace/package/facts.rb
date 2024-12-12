require 'yaml'
require 'erb'

class PackageFacts
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

  def flavor_with the_flavor
    if has_flavors? && the_flavor.nil?
      raise FlavorArgumentRequired.new flavors
    elsif has_flavors? && the_flavor != false
      flavor! the_flavor
    end
  end

  def config_files
    if has_config_files?
      @facts["config_files"].flatten.map do |path|
        Pathname.glob(@package_path + path).delete_if do |match|
          match.directory? and path.include? "*"
        end
      end.flatten
    else [] end
  end

  def has_config_files?
    has_key? 'config_files'
  end

  def has_flavors?
    @unflavorable_facts && !@unflavorable_facts["flavors"].nil?
  end

  def has_key? key
    @unflavorable_facts && (@unflavorable_facts.has_key?(key) or @facts.has_key?(key))
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

  def flavor! the_flavor
    raise PackageFlavorDoesNotExist.new(the_flavor, flavors) unless flavors.include? the_flavor
    @facts = @unflavorable_facts["flavors"][the_flavor]
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
      rendered_manifest = ERB.new(@facts_file.read, trim_mode: '-').result(binding)
    rescue Exception => e
      raise ManifestErbError.new(self, e)
    end
    value = YAML.load rendered_manifest, aliases: true
    if value.is_a?(String) && value == "---"
      return Hash.new
    else
      value
    end
  end
end


