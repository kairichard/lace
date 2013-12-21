class UsageError < RuntimeError; end
class ResourceNotSpecified < ArgumentError; end
class ErrorDuringExecution < RuntimeError; end

FlavorArgumentMsg = <<-EOS
Sorry, this command needs a flavor argument you can choose from the following:
- %s
EOS
