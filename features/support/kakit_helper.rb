require 'debugger'

module ZimtHelper
  def chmod(mode, name)
    in_current_dir do
      raise "expected #{name} to be present" unless FileTest.exists?(name)
      if mode.kind_of? String
        FileUtils.chmod(mode.to_i(8),name)
      else
        FileUtils.chmod(mode,name)
      end
    end
  end

  def kit_from_fixture name, options={}
    flavor = options[:flavor] || 'simple'
    target = File.join(ENV["KAKITS_FOLDER"], name)
    FileUtils.cp_r File.expand_path("fixtures/kits/#{flavor}/") + "/.", target
  end
end

World ZimtHelper
