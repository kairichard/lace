HELP = <<-EOS
Example usage:
  Synopsis:
    lace <cmd> <pkg-uri/name> [<flavor>] [--name=<name>] [--version] [--no-hooks] [--force]

  lace ls

  lace fetch <pkg-uri>
  lace fetch <pkg-uri>

  lace setup <pkg-uri>
  lace setup <pkg-uri> <flavor>

  lace activate <pkg-name>
  lace activate <pkg-name> <flavor>

  lace deactivate <pkg-name>
  lace deactivate <pkg-name> <flavor>

  lace remove <pkg-name>
  lace update <pkg-name>

Troubleshooting:
  lace help
  lace info <pkg-name>
  lace validate <local-directory>
  lace --version

For further help visit:
  https://github.com/kairichard/lace
EOS

module Lace extend self
  def help
    puts HELP
  end
  def help_s
    HELP
  end
end
