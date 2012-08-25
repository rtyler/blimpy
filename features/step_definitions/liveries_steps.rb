Given /^the following Blimpfile contents:$/ do |buffer|
  @blimpfile = buffer
end

When /^I evaluate the Blimpfile$/ do
  @blimpfile.should_not be_nil
  @fleet = eval(@blimpfile)
end

Then /^the CWD livery should be set up$/ do
  @fleet.should_not be_nil
  @fleet.ships.first.livery.should == Blimpy::Livery::CWD
end

Then /^the Puppet livery should be correctly configured$/ do
  @fleet.should_not be_nil
  @fleet.ships.first.livery.should be_instance_of(Blimpy::Livery::Puppet)
end

