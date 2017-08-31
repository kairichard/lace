module LaceHelper
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
    expanded_target_path = File.expand_path(File.join(current_directory, target_path, "/"))
    FileUtils.cp_r(File.expand_path("fixtures/git/working/") + '/.', expanded_target_path)
    Dir.chdir(expanded_target_path) do
      FileUtils.mv('dot_git', '.git')
    end
  end

  def _mv from, to
    in_current_dir do
      FileUtils.mv from, to
    end
  end
end

World LaceHelper
