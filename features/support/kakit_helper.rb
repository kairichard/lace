require 'debugger'
module KakitHelper
  def kit_from_fixture name, options={}
      flavor = options[:flavor] || 'simple'
      target = File.join(ENV["KAKITS_FOLDER"], name)
      FileUtils.cp_r File.expand_path("fixtures/kits/#{flavor}/") + "/.", target
  end
end

World KakitHelper
