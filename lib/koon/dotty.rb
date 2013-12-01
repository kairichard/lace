require 'koon/download_strategy'
require 'koon/os/simple_packet_manager'
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
			@facts["postinstall"] || []
		end
		
		def dependencies
			@facts["dependencies"] || []
		end
		
		def has_unsatisfied_depnedencies?
			dependencies.map do |dep|
				SimplePacketManagerWrapper.present? dep
			end.one?{|d| d == false }
		end
  end

  def initialize url=nil, &block
    @url = url
  end

  def downloader
    @downloader ||= download_strategy.new(url)
  end

  def download_strategy
    @download_strategy ||= DownloadStrategyDetector.detect(url)
  end

  def install(target=nil)
		# when we do have broken facts this fails
		read_facts!	
		if is_installed? and is_active?
			deactivate!
		end
		if @facts.has_unsatisfied_depnedencies?
			SimplePacketManagerWrapper.install @facts.dependencies
		end
		downloader.fetch
		activate!
		@facts.post_install_commands.each do |cmd|
			safe_system cmd
		end
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
			raise "there a more than one active dotty - which is not supported ATM"
		end	
	end

	def read_facts!
			@facts = Dotty::Facts.new downloader.target_folder 
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
