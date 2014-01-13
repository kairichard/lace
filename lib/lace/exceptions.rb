class UsageError < RuntimeError; end
class ResourceNotSpecified < ArgumentError; end
class ErrorDuringExecution < RuntimeError; end

class OnlyGitReposCanBeUpdatedError < RuntimeError
  def initialize
    super "Only pkgs installed via git can be updated"
  end
end

class AlreadyActiveError < RuntimeError
  def initialize
    super "Cannot activate an already active package, please deactivate first"
  end
end

class NonActiveFlavorError < RuntimeError
  def initialize
    super "Cannot deactivate package that is not active"
  end
end

class PackageAlreadyInstalled < RuntimeError
  def initialize
    super "Package already installed"
  end
end

class CannotRemoveActivePackage < RuntimeError
  def initialize
    super "Cannot remove active pkg, deactivate first"
  end
end

class PackageNotInstalled < RuntimeError
  def initialize name
    super "Package #{name} is not installed"
  end
end

class FlavorError < RuntimeError; end

class FlavorArgumentRequired < FlavorError
  def initialize available_flavors
    super FlavorArgumentMsg % available_flavors.join("\n- ")
  end
end

class PackageFactsNotFound < RuntimeError
  def initialize path
    super "No PackageFacts found in #{path}"
  end
end

class PackageFlavorDoesNotExist < FlavorError
  def initialize which_flavor, flavors
    super "Flavor '#{which_flavor}' does not exist"
  end
end

class ManifestErbError < RuntimeError
  def initialize fact, exception
    super "#{exception.exception}\nin #{fact.facts_file}"
  end
end


FlavorArgumentMsg = <<-EOS
Sorry, this command needs a flavor argument you can choose from the following:
- %s
EOS
