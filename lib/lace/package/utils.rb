require 'lace/exceptions'

class PackageUtils

  def self.fetch uri
    downloader = DownloadStrategyDetector.detect(uri).new(uri)
    raise PackageAlreadyInstalled.new if downloader.target_folder.exist?
    downloader.fetch
    return downloader.name, downloader.target_folder
  end

  def self.remove package_name
    package = Package.new package_name, false
    raise CannotRemoveActivePackage.new if package.is_active?
    ohai "Removing"
    FileUtils.rm_rf package.path
  end

  def self.setup package_name
    begin
      package = Package.new package_name, ARGV.first
      package.activate!
      package.setup
    rescue FlavorError => e
      onoe e.message
      onoe "Package remains installed but was not activated"
    end
  end

  def self.deactivate package_name
    package = Package.new package_name, ARGV.first
    raise NonActiveFlavorError.new unless package.is_active? || ARGV.force?
    ohai "Deactivating"
    package.deactivate!
  end

  def self.activate package_name
    package = Package.new package_name, ARGV.first
    raise AlreadyActiveError.new if Package.new(package_name, false).is_active?
    ohai "Activating"
    package.activate!
  end

  def self.update package_name
    package = Package.new package_name, false
    raise OnlyGitReposCanBeUpdatedError.new unless package.is_git_repo?
    updater = GitUpdateStrategy.new package_name
    was_active_before_update = package.is_active?
    self.deactivate(package_name) if was_active_before_update
    ohai "Updating"
    updater.update
    self.activate(package_name) if was_active_before_update
    package = Package.new package_name, false
    package.after_update
  end
end


