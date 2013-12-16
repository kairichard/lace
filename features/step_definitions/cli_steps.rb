Given(/^an installed kit named "(.*?)"$/) do |kit_name|
    kit_from_fixture kit_name
end

Given(/^an active kit with flavors named "(.*?)"$/) do |kit_name|
    kit_from_fixture kit_name, :flavor => "osx"
    step "I run `dotkoon activate #{kit_name} osx`"
end

Given(/^an installed kit with flavors named "(.*?)"$/) do |kit_name|
    kit_from_fixture kit_name, :flavor => "osx"
end

Given(/^an active kit named "(.*?)"$/) do |kit_name|
    step "an installed kit named \"#{kit_name}\""
    step "I run `dotkoon activate #{kit_name}`"
end
