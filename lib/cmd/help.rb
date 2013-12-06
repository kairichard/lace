HELP = <<-EOS
Here should be a big help message
EOS
module Koon extend self
  def help
    puts HELP
  end
  def help_s
    HELP
  end
end
