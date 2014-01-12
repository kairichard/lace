require 'erb'

require 'lace/package'
require 'lace/utils'
require 'lace/exceptions'

VALIDATE = <<-EOS
Lace-Manifest Validation Report:
<% validation.errors.each do |error| -%>
  <%= "%-58s [ %s ]" % [error[0] + ':', error[1]] %>
<% unless error[2].nil? -%>
<% error[2].each do |line| -%>
    <%= Tty.gray %><%= '# '+line.to_s %><%= Tty.reset %>
<% end -%>
<% end -%>
<% end -%>
EOS

module Lace extend self
	def validate
		resource = ARGV.shift
		raise ResourceNotSpecified if not resource
    validation = PackageValidator.new Facts.new(resource), ARGV.shift
    puts ERB.new(VALIDATE, nil, '-').result(binding)
    Lace.failed = true if validation.has_errors?
	end
end

class PackageValidator
  attr_accessor :errors

  class << self
    attr_accessor :validations
    def validate name, method_name
      @validations ||= []
      @validations << [name, method_name]
    end
  end

  validate 'config-files', :config_files_present
  validate 'version', :version_present
  validate 'homepage', :homepage_present
  validate 'setup', :setup_ok
  validate 'post-update hook', :post_update_hooks_ok

  def initialize facts, flavor=nil
    @facts = facts
    @errors = []
    if @facts.has_flavors? && flavor.nil?
      raise RuntimeError.new FlavorArgumentMsg % @facts.flavors.join("\n- ")
    elsif @facts.has_flavors? && flavor != false
      @facts.flavor! flavor
    end
    validate
  end

  def check_hooks hook_cmd
    hook_cmd.map do |cmd|
      if !File.exist? cmd
         "#{cmd} cannot be found"
      elsif !File.executable? cmd
        "#{cmd} is not executable"
      end
    end.compact
  end

  def hook_ok config_files
    hook_cmd = config_files
    if hook_cmd.empty?
      ["#{Tty.green}skipped#{Tty.reset}", nil]
    else
      errors = check_hooks hook_cmd
      if errors.length > 0
        ["#{Tty.red}error#{Tty.reset}", errors]
      else
        ["ok", nil]
      end
    end
  end

  def setup_ok
    hook_ok @facts.setup_files
  end

  def post_update_hooks_ok
    hook_ok @facts.post :update
  end

  def homepage_present
    if @facts.has_key? 'homepage'
      ["#{Tty.green}found#{Tty.reset}", nil]
    else
      ["#{Tty.red}missing#{Tty.reset}", ['adding a homepage improves the credibility', 'of your package']]
    end
  end

  def version_present
    if @facts.has_key? 'version'
      ["#{Tty.green}found#{Tty.reset}", nil]
    else
      ["#{Tty.red}missing#{Tty.reset}", ['adding a version to the manifest improves', 'a future update experince']]
    end
  end

  def config_files_present
    if @facts.config_files.empty?
      ["#{Tty.red}missing#{Tty.reset}", ['Add config_files see manual for more information']]
    elsif @facts.config_files.any?{|f| !File.exist? f}
      ["#{Tty.red}error#{Tty.reset}", @facts.config_files.select{|f| !File.exist? f}.map{|f| "#{f.to_s.split("/").last} is missing from this package"}]
    else
      ["#{Tty.green}found#{Tty.reset}", nil]
    end
  end

  def validate
    self.class.validations.each do |validation|
      errors << [validation[0], *send(validation[1])]
    end
  end

  def has_errors?
    errors.any?{|e| !e[2].nil? }
  end
end
