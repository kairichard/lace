@wip
Feature: Diffing files 
  As a user I want to see which files have not yet been linked
  This serves more as a means to debug when developing new config files locally

  Background:
    Given a package named "cassia/simple" with the following manifest:
    """
    ---
    config_files:
      - bashrc
    """
    And an empty file named "cassia/simple/bashrc"
    And I run `lace fetch cassia/simple`
    And I run `lace activate simple`


  Scenario:
    Given a file named "installed_cassias/simple/.lace.yml" with:
    """
    ---
    config_files:
      - zshrc
      - anotherrc
    """
    And an empty file named "installed_cassias/simple/zshrc"
    And an empty file named "installed_cassias/simple/anotherrc"
    And I run `lace diff simple`
    Then the output should contain:
    """
    [+] zshrc -> $HOME/.zshrc
    [+] anotherrc -> $HOME/.anotherrc
    [-] bashrc -> $HOME/.bashrc
    """

  Scenario:
    Given a file named "installed_cassias/simple/.lace.yml" with:
    """
    ---
    config_files:
      - zshrc
      - config/**/*
    """
    And an empty file named "installed_cassias/simple/config/nvim/init.lua"
    And an empty file named "HOME/config/nvim/plugin.lua"
    And I run `lace diff simple`
    Then the output should contain:
    """
    [+] init.lua -> $HOME/.config/nvim/init.lua
    [-] bashrc -> $HOME/.bashrc
    """

  Scenario:
    Given a file named "installed_cassias/simple/.lace.yml" with:
    """
    ---
    config_files:
      - zshrc
    """
    And an empty file named "installed_cassias/simple/config/nvim/init.lua"
    And an empty file named "HOME/config/nvim/init.lua"
    And I link "installed_cassias/simple/config/nvim/init.lua" to "HOME/config/nvim/init.lua" 
    And I run `lace diff simple`
    Then the output should contain:
    """
    [-] init.lua -> $HOME/.config/nvim/init.lua
    [-] bashrc -> $HOME/.bashrc
    """
