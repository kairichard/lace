# frozen_string_literal: true

require('lace/exceptions')

Diff = Struct.new(:added, :removed) do
end

class PackageUtils
  def self.fetch(uri, desired_package_name = nil)
    downloader_cls = DownloadStrategyDetector.detect(uri)
    downloader = downloader_cls.new(uri, desired_package_name)
    raise(PackageAlreadyInstalled, downloader.target_folder) if downloader.target_folder.exist?

    downloader.fetch
    [downloader.name, downloader.target_folder]
  end

  def self.remove(package_name)
    package = Package.new(package_name, false)
    raise(CannotRemoveActivePackage) if package.is_active?

    ohai('Removing')
    FileUtils.rm_rf(package.path)
  end

  def self.setup(package_name)
    package = Package.new(package_name, ARGV.first)
    package.activate!
    package.setup
  rescue FlavorError => e
    onoe(e.message)
    onoe('Package remains installed but was not activated')
  end

  def self.deactivate(package_name)
    package = Package.new(package_name, ARGV.first)
    raise(NonActiveFlavorError) unless package.is_active? || ARGV.force?

    ohai('Deactivating')
    package.deactivate!
  end

  def self.activate(package_name)
    package = Package.new(package_name, ARGV.first)
    raise(AlreadyActiveError) if Package.new(package_name, false).is_active?

    ohai('Activating')
    package.activate!
  end

  def self.update(package_name)
    package = Package.new(package_name, false)
    raise(OnlyGitReposCanBeUpdatedError) unless package.is_git_repo?

    updater = GitUpdateStrategy.new(package_name)
    was_active_before_update = package.is_active?
    deactivate(package_name) if was_active_before_update
    ohai('Updating')
    updater.update
    activate(package_name) if was_active_before_update
    package = Package.new(package_name, false)
    package.after_update
  end

  def self.diff(package_name)
    home_dir = Dir.home
    package = Package.new(package_name, ARGV.first)
    config_files = Set.new(package.facts.config_files)
    files_pointing_to_package = Set.new(symlinks_to_package(package).map { |f| Pathname.new(File.readlink(f)) })
    files_from_manifest_not_in_home = Set.new(config_files.reject do |f|
      f.as_dotfile(home_dir, package.path).exist?
    end)
    Diff.new(files_from_manifest_not_in_home, (files_pointing_to_package - config_files))
  end

  def self.symlinks_to_package(package)
    home_dir = Dir.home
    found_links = Set.new
    traverse_directory(home_dir, package) { |entry| (found_links << entry) }
    found_links
  end
end

COMMON_CONFIG_FOLDERS = ['config'].freeze

def traverse_directory(directory, package, &block)
  package_path = package.path
  whitelisted_folders = package.facts.globbed_folder + COMMON_CONFIG_FOLDERS
  Dir.foreach(directory) do |entry|
    next if ['.', '..'].include?(entry)

    entry_path = File.join(directory, entry)
    if File.symlink?(entry_path) && File.readlink(entry_path).include?(package_path)
      block.call(entry_path)
    elsif File.directory?(entry_path) && whitelisted_folders.any? { |f| entry_path.include?(f) }
      traverse_directory(entry_path, package, &block)
    end
  end
end
