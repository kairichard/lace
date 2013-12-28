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

  def create_temp_repo(target_path)
    FileUtils.cp_r(File.expand_path("fixtures/git/working/") + '/.', File.join(current_dir, target_path))
    in_current_dir do
      Dir.chdir(target_path) do
        FileUtils.mv('dot_git', '.git')
      end
    end
  end

  def _mv from, to
    in_current_dir do
      FileUtils.mv from, to
    end
  end
end

World ZimtHelper
