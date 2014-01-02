Zimt - dotfile management
========
Logging in to different machines at work/home I just wanted to have an elegant solution to install configurations on them. Zimt provides. Also i wanted something that makes it real easy to bootstrap a new maschine, even if they are differently flavored. Zimt provides. And i hoped for something that lets you share common dotfiles with your teammates by just installing them next to your own dotfiles.
Zimt is inspired by brew.
###### Synopsis
```bash
zimt <cmd> <pkg-uri/name> [--name=<name>] [--version] [--no-hooks]
```
Installing
-------------
Zimt comes as a gem, so given you have ruby install simply do the following
```bash
> gem install zimt
```
Usage
-----------
### Installing a Package
Its possible to install a Package either locally via the files system or by specifying a remote git repo,
local git repos also works. **Installing means that a package is fetched and then activated**.

```bash
# install something from disk
> zimt install somewhere/on/mydisk
# or from github
> zimt install https://github.com/kairichard/example_dotfile_pkg.git
# for some config files to take effect it may be required to reload your current terminal session
```

### Playing around with a non intrusive example package
Most likely you dont want to override your existing config files just to get a feeling on how zimt
behaves. Therefore i prepared an example package for you to just install and play around with.
```bash
> zimt fetch https://github.com/kairichard/example_dotfile_pkg.git
> zimt activate example_dotfile_pkg
```

```
Example usage:
  Synopsis:
    zimt <cmd> <pkg-uri/name> [<flavor>] [--name=<name>] [--version] [--no-hooks]

  zimt ls

  zimt fetch <pkg-uri>
  zimt fetch <pkg-uri>

  zimt install <pkg-uri>
  zimt install <pkg-uri> <flavor>

  zimt activate <pkg-name>
  zimt activate <pkg-name> <flavor>

  zimt deactivate <pkg-name>
  zimt deactivate <pkg-name> <flavor>

  zimt remove <pkg-name>
  zimt update <pkg-name>

Troubleshooting:
  zimt help
  zimt info <pkg-name>
  zimt validate <local-directory>
```
- - -
## Learning how to make your own package
A good staring point is to look at the output of `zimt inspect`. Given you have installed the example_dotfile_pkg
you can run the following command:
```bash
> zimt inspect example_dotfile_pkg
Inspection of example_dotfile_pkg:
  active:      true
  flavors:     osx, linux, production
  version:     0.1
  upgradeable: true
  manifest:    ~/.cassias/example_dotfile_pkg/.zimt.yml
  homepage:    https://github.com/kairichard/example_dotfile_pkg
```
Than just take a look at the `.zimt.yml` to learn some more and eventually make your own package.
### Validating your own package
When packaging your zimt-package you may want to validate your `.zimt.yml` to do that just run the following and study the output to improve your package
```bash
> zimt validate somewhere/on/mydisk
Zimt-Manifest Validation Report:
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
**NOTE** `zimt validate` only works with local directories

## Contributing Code

If you want to contribute code, please try to:

* Follow the same coding style as used in the project. Pay attention to the
  usage of tabs, spaces, newlines and brackets. Try to copy the aesthetics the
  best you can.
* Add an scenario under `features` that verifies your change (test with `rake features`). Look at the existing test
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
  * interactive-mode
    * flavor choosing
    * run hooks y/n


License
--------
MIT License (MIT)

Copyright (c) 2014 Kai Richard Koenig
