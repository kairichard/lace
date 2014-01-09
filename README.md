Lace - dotfile management [![Build Status](https://travis-ci.org/kairichard/lace.png?branch=master)](https://travis-ci.org/kairichard/lace)
========
Logging in to different machines at work or at home I just wanted to have an elegant solution to install .dotfiles on them. Lace provides. Also I wanted something that makes it real easy to bootstrap a new maschine, even if they are differently flavored. Lace provides. Updateing these should be a breeze. Lace provides. And I hoped for something that lets you share common .dotfiles with your teammates by just installing them next to your own dotfiles. Lace provides.
Lace is inspired by brew.
###### Synopsis
```bash
lace <cmd> <pkg-uri/name> [--name=<name>] [--version] [--no-hooks]
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
local git repos also work. **Installing means that a package is fetched and then activated**.

```bash
# install something from disk
> lace install somewhere/on/mydisk
# or from github
> lace install https://github.com/user/repo.git <flavor>
# for some config files to take effect it may be required to reload your current terminal session
```

### Playing around with a non intrusive example package
Most likely you dont want to override your existing config files just to get a feeling on how lace
behaves. Therefore I prepared an example package for you to just install and play around with.
```bash
> lace fetch https://github.com/kairichard/lace_example_dotfile_pkg.git
> lace activate lace_example_dotfile_pkg
```

```
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
  post-install hook:                                         [ error ]
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
  * refactor hook invocation
  * refactor validate.rb
  * erb in .lace.yml
  * what happens if you download something that doesnt have package facts ?
    * remove package with a notice
  * if installing fails due to missing flavor hooks arent executed
    * remains installed but not active
  * improve list mode to show if uptodate and show version
  * interactive-mode
  * override existing files check
    * force override of existing
  * yes mode
    * flavor choosing on install
    * run hooks y/n
  * updating from no flavor to a config with flavors
    * may be through a default flavor which is used when there is no flavor available
  * lace open

License
--------
MIT License (MIT)

Copyright (c) 2014 Kai Richard Koenig
