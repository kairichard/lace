require 'koon/download_strategy'
require 'yaml'

class Dotty

  attr_reader :name
  attr_writer :url

	class Facts
		def initialize location
			@location = Pathname.new(location)
			@facts_file = @location + "dotty.yml"
			raise RuntimeError.new "No dotty file found in #@location" unless @facts_file.exist?
			@facts = YAML.load @facts_file.read
		end
						
		def config_files
			@facts["config_files"].map do |file|
				@location + file
			end
		end		
	
		def post_install_commands	
			@facts["post_install"]
		end
		
		def has_unsatisfied_depnedencies?
			dependecies.map do |dep|
				SimplePacketManagerWrapper.present? dep
			end.one?{|d| d == false }
		end
  end

  def initialize url=nil, &block
    @url = url
    #instance_eval(&block) if block_given?
  end

  def downloader
    @downloader ||= download_strategy.new(url)
  end

  def download_strategy
    @download_strategy ||= DownloadStrategyDetector.detect(url)
  end

  def install(target=nil)
		location = downloader.fetch
    facts = gather_facts_from location
		if facts.has_unsatisfied_depnedencies?
			SimplePacketManagerWrapper.install facts.dependencies
		end
		link_into_home facts.config_files
		facts.post_install_commands.each do |cmd|
			safe_system cmd
		end
  end

	def gather_facts_from location
			Dotty::Facts.new location
	end	

	def link_into_home files
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
