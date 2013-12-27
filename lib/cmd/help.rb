HELP = <<-EOS
Example usage:
  zimt ls

  zimt fetch <pkg-uri>
  zimt fetch <pkg-uri> --name=<name>

  zimt install <pkg-uri> --name=<name>
  zimt install <pkg-uri> <flavor> --name=<name>

  zimt activate <pkg-name>
  zimt activate <pkg-name> <flavor>

  zimt deactivate <pkg-name>
  zimt deactivate <pkg-name> <flavor>

  zimt remove <pkg-name>

Troubleshooting:
  zimt help
  zimt info <pkg-name>
  zimt validate <pkg-name>

For further help visit:
  https://github.com/kairichard/zimt
EOS

module Koon extend self
  def help
    puts HELP
  end
  def help_s
    HELP
  end
end
