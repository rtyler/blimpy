
Given /^I have no Blimpfile in my current directory$/ do
  # no-op: default state of the world is to not have a Blimpfile!
end

Given /^I have the Blimpfile:$/ do |string|
  create_blimpfile(string)
end

Given /^I have a single VM running$/ do
  create_blimpfile(
    """
    Blimpy.fleet do |f|
      f.add do |host|
        host.name = 'Failboat'
      end
    end
    """)
  d = File.join(@tempdir, '.blimpy.d')
  Dir.mkdir(d)
  @name = 'Cucumber host'
  @server_id = '0xdeadbeef'
  File.open(File.join(d, "#{@server_id}.blimp"), 'w') do |f|
    f.write("name: #{@name}\n")
    f.write("dns: foo.bar\n")
  end
end

Then /^the output should list the VM$/ do
  expected = 'Cucumber host (0xdeadbeef) is: online at foo.bar'
  assert_partial_output(expected, all_output)
end
