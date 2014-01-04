Feature: Display a help message
  A help message should be provided when executable
  is invoked with the usual help flags.

  Scenario: Invoking with helpflag
    When I successfully run `lace -h`
    Then the output should contain:
    """
    Example usage:
      Synopsis:
        lace <cmd> <pkg-uri/name> [<flavor>] [--name=<name>] [--version] [--no-hooks]

      lace ls

      lace fetch <pkg-uri>
      lace fetch <pkg-uri>

      lace install <pkg-uri>
      lace install <pkg-uri> <flavor>

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

    For further help visit:
      https://github.com/kairichard/lace
    """


