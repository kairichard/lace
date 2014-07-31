Lace - dotfile management
========
[![Build Status](https://travis-ci.org/kairichard/lace.png?branch=master)](https://travis-ci.org/kairichard/lace) [![Gem Version](https://badge.fury.io/rb/lace.png)](http://badge.fury.io/rb/lace) [![Dependency Status](https://gemnasium.com/kairichard/lace.svg)](https://gemnasium.com/kairichard/lace) [![Coverage Status](https://coveralls.io/repos/kairichard/lace/badge.png?branch=master)](https://coveralls.io/r/kairichard/lace?branch=master)


Logging in to different machines at work or at home I just wanted to have an elegant solution to install .dotfiles on them. Lace provides. Also I wanted something that makes it real easy to bootstrap a new maschine, even if they are differently flavored. Lace provides. Updating these should be a breeze. Lace provides. And I hoped for something that lets you share common .dotfiles with your teammates by just installing them next to your own dotfiles. Lace provides.
Lace is inspired by brew.
###### Synopsis
```bash
lace <cmd> <pkg-uri/name> [--name=<name>] [--version] [--no-hooks] [--force]
```
Installing
-------------
Lace comes as a gem, so given you have ruby installed simply do the following
```bash
> gem install lace
#or
> git clone https://github.com/kairichard/lace.git
> cd lace
> gem build lace.gemspec
> gem install lace-*.gem
```
Usage
-----------
### Installing a Package
Its possible to install a Package either locally via the files system or by specifying a remote git repo,
local git repos also work.

```bash
# install something from disk
> lace fetch somewhere/mydofiles
> lace setup mydofiles
# or from github
> lace fetch https://github.com/user/repo.git
> lace setup user <flavor>
# or name it the way you like
> lace fetch https://github.com/user/repo.git --name=prod
> lace setup prod <flavor>
# for some config files to take effect it may be required to reload your current terminal session
```

### Playing around with a non intrusive example package
Most likely you dont want to override your existing config files just to get a feeling on how lace
behaves. Therefore I prepared an example package for you to just install and play around with.
```bash
> lace fetch https://github.com/kairichard/lace_example_dotfile_pkg.git
> lace setup lace_example_dotfile_pkg
```

```
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
```
- - -
## Learning how to make your own package
A good staring point is to look at the output of `lace inspect`. Given you have installed the lace_example_dotfile_pkg
you can run the following command:
```bash
> lace inspect lace_example_dotfile_pkg
Inspection of lace_example_dotfile_pkg:
  active:      true
  flavors:     osx, linux, production
  version:     0.1
  upgradeable: true
  manifest:    ~/.cassias/lace_example_dotfile_pkg/.lace.yml
  homepage:    https://github.com/kairichard/lace_example_dotfile_pkg
```
Than just take a look at the `.lace.yml` to learn some more and eventually make your own package.
### Validating your own package
When packaging your lace-package you may want to validate your `.lace.yml` to do that just run the following and study the output to improve your package
```bash
> lace validate somewhere/on/mydisk
Lace-Manifest Validation Report:
  config-files:                                              [ error ]
    # arkrc is missing from this package
  version:                                                   [ missing ]
    # adding a version to the manifest improves
    # a future update experince
  homepage:                                                  [ missing ]
    # adding a homepage improves the credibility
    # of your package
  setup:                                                     [ error ]
    # ~/.vim/install_bundles cannot be found
    # ~/.bootstrap/osx/brew cannot be found
    # ~/.bootstrap/osx/defaults cannot be found
    # ~/.bootstrap/osx/fonts cannot be found
  post-update hook:                                          [ error ]
    # ~/.vim/install_bundles cannot be found
    # ~/.bootstrap/osx/brew cannot be found
```
**NOTE** `lace validate` only works with local directories

## Contributing Code

If you want to contribute code, please try to:

* Follow the same coding style as used in the project. Pay attention to the
  usage of tabs, spaces, newlines and brackets. Try to copy the aesthetics the
  best you can.
* Add a scenario under `features` that verifies your change (test with `rake features`). Look at the existing test
  suite to get an idea for the kind of tests I like. If you do not provide a
  test, explain why.
* Write [good commit messages](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html),
  explain what your patch does, and why it is needed.
* Keep it simple: Any patch that changes a lot of code or is difficult to
  understand should be discussed before you put in the effort.

Once you have tried the above, create a GitHub pull request to notify me of your
changes.

## TODO
  * execute hook allow interaction
  * info should show local modifications
    * add mothership communication which notifies you about changes in the different environments
  * description in lace ls
  * Update without having to deactivate
    * figure out which is the active flavor
      * the one with smallest delta of matching to non matching config_files
    * build the diff between the old and new config
    * only link the diff
  * Track events with PStore ?
  * define a pkg.lace where i can define multiple pkgs to be fetched and setup
  * Refactor
    * move hooks away from the package itself into the Utils
    * hook invocation
    * validate.rb
    * facts key access
    * exceptions.rb has code duplication

License
--------
MIT License (MIT)

Attribution
--------
Thanks to the people creating and maintaining Homebrew. Without their prior work this tool would probably not exist.
And if it did it would be in a worse state than it is today.

