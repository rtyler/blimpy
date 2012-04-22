
Given /^I have no Blimpfile in my current directory$/ do
  # no-op: default state of the world is to not have a Blimpfile!
end

Given /^I have the Blimpfile:$/ do |string|
  path = File.join(@tempdir, 'Blimpfile')
  File.open(path, 'w') do |f|
    f.write(string)
  end
end
