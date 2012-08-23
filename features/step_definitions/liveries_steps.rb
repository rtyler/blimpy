Given /^the following Blimpfile contents:$/ do |buffer|
  @blimpfile = buffer
end

When /^I evaluate the Blimpfile$/ do
  @blimpfile.should_not be_nil
  @fleet = eval(@blimpfile)
  @fleet.should_not be_nil
end

Then /^the "([^"]*)" livery should be set up$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

