HELP = <<-EOS
Merly a test
EOS
module Koon extend self
  def help
    puts HELP
  end
  def help_s
    HELP
  end
end
