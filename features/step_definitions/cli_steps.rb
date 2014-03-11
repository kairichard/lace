Given(/^an installed pkg named "(.*?)"$/) do |name|
    target = File.join @installed_cassias, name
    step "a directory named \"#{target}\""
    step "an empty file named \"#{target}/bashrc\""
    step "a file named \"#{target}/.lace.yml\" with:", SIMPLE_LACE
end

Given(/^an active pkg with flavors named "(.*?)"$/) do |name|
    step "an installed pkg with flavors named \"#{name}\""
    step "I run `lace activate #{name} osx`"
end

Given(/^an installed pkg with flavors named "(.*?)"$/) do |name|
    target = File.join @installed_cassias, name
    step "a directory named \"#{target}\""
    step "an empty file named \"#{target}/bashrc\""
    step "a file named \"#{target}/.lace.yml\" with:", FLAVORED_LACE
end

Given(/^an active pkg named "(.*?)"$/) do |pkg_name|
    step "an installed pkg named \"#{pkg_name}\""
    step "I run `lace activate #{pkg_name}`"
end

Given(/^a file named "([^"]*)" with mode "([^"]*)" and with:$/) do |file_name, file_mode, file_content|
    write_file(file_name, file_content)
    chmod(file_mode, file_name)
end

Given(/^the file named "([^"]*)" has mode "([^"]*)"$/) do |file_name, file_mode|
  chmod(file_mode, file_name)
end

Then(/^the folder "([^"]*)" should be empty$/) do |folder_name|
  in_current_dir do
    expect(Dir.glob(File.join(folder_name, "**/*"))).to be_empty
  end
end

Given(/^I rename "(.*?)" to "(.*?)"$/) do |from, to|
  _mv from, to
end

Given(/^a git repo in a directory named "(.*?)"$/) do |dir_name|
   create_dir(dir_name)
   create_temp_repo(dir_name)
end

Given(/^a package named "(.*?)" with the following manifest:$/) do |name, manifest|
    step "a directory named \"#{name}\""
    step "a file named \"#{name}/.lace.yml\" with:", manifest
end

Given(/^a git-package named "(.*?)" with the following manifest:$/) do |name, manifest|
    step "a directory named \"#{name}\""
    create_temp_repo(name)
    step "a file named \"#{name}/.lace.yml\" with:", manifest
end

Then(/^I git\-commit "(.*?)" saying "(.*?)"$/) do |dir, commit_msg|
    step "I cd to \"#{dir}\""
    step "a directory named \".git\" should exist"
    step "I run `git add .`"
    step "I run `git commit -am \'#{commit_msg}\'`"
    up_dir = dir.gsub(/\b\w+\b/, "..")
    step "I cd to \"#{up_dir}\""
end

SIMPLE_LACE = """
---
config_files:
  - bashrc
"""

FLAVORED_LACE = """
---
flavors:
  osx:
    config_files:
      - bashrc
"""


