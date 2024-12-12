module LaceHelper
  def chmod(mode, name)
    cd(".") do
      raise "expected #{name} to be present" unless FileTest.exist?(name)
      if mode.kind_of? String
        FileUtils.chmod(mode.to_i(8),name)
      else
        FileUtils.chmod(mode,name)
      end
    end
  end

  def create_temp_repo(target_path)
    expanded_target_path = File.expand_path(File.join(expand_path("."), target_path, "/"))
    FileUtils.cp_r(File.expand_path("fixtures/git/working/") + '/.', expanded_target_path)
    Dir.chdir(expanded_target_path) do
      FileUtils.mv('dot_git', '.git')
    end
  end

  def _mv from, to
    cd(".") do
      FileUtils.mv from, to
    end
  end
end

World LaceHelper
