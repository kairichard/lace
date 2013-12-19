Given(/^an installed kit named "(.*?)"$/) do |name|
    target = File.join @installed_cassias, name
    step "a directory named \"#{target}\""
    step "an empty file named \"#{target}/bashrc\""
    step "a file named \"#{target}/dotty.yml\" with:", SIMPLE_DOTTY
end

Given(/^an active kit with flavors named "(.*?)"$/) do |name|
    step "an installed kit with flavors named \"#{name}\""
    step "I run `dotkoon activate #{name} osx`"
end

Given(/^an installed kit with flavors named "(.*?)"$/) do |name|
    target = File.join @installed_cassias, name
    step "a directory named \"#{target}\""
    step "an empty file named \"#{target}/bashrc\""
    step "a file named \"#{target}/dotty.yml\" with:", FLAVORED_DOTTY
end

Given(/^an active kit named "(.*?)"$/) do |kit_name|
    step "an installed kit named \"#{kit_name}\""
    step "I run `dotkoon activate #{kit_name}`"
end

Given(/^a file named "([^"]*)" with mode "([^"]*)" and with:$/) do |file_name, file_mode, file_content|
    write_file(file_name, file_content)
    chmod(file_mode, file_name)
end

Given(/^the file named "([^"]*)" has mode "([^"]*)"$/) do |file_name, file_mode|
  chmod(file_mode, file_name)
end

Given(/^I rename "(.*?)" to "(.*?)"$/) do |from, to|
  _mv from, to
end

SIMPLE_DOTTY = """
---
config_files:
  - bashrc
"""

FLAVORED_DOTTY = """
---
flavors:
  osx:
    config_files:
      - bashrc
"""


