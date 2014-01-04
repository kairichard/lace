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
    super "It looks like the flavor you tried to deactivate is not active after all"
  end
end

FlavorArgumentMsg = <<-EOS
Sorry, this command needs a flavor argument you can choose from the following:
- %s
EOS
