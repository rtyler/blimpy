
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
    f.write(":name: #{@name}\n")
    f.write(":dns: foo.bar\n")
  end
end

Given /^I have a file named "([^"]*)"$/ do |filename|
  File.open(filename, 'w') do |fd|
    fd.write("I am #{filename}\n")
  end
end

When /^I ssh into the machine$/ do
  step %{I run `blimpy start`}
  step %{I run `blimpy ssh "Cucumber Host" -o StrictHostKeyChecking=no` interactively}
end

Then /^the output should list the VM$/ do
  expected = 'Cucumber host (0xdeadbeef) is: online at foo.bar'
  assert_partial_output(expected, all_output)
end

Then /^the output should contain the right DNS info$/ do
  terminate_processes!
  internal_name = nil
  Dir["#{@tempdir}/.blimpy.d/*.blimp"].each do |filename|
    data = YAML.load_file(filename)
    internal_name = data['internal_dns']
    break unless internal_name.nil?
  end
  step %{the output should contain "#{internal_name}"}
end
