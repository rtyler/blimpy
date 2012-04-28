Before do
  @cwd = Dir.pwd
  @tempdir = TempDir.create(:basename => 'blimpy_test')
  puts "Using tempdir: #{@tempdir}"
  Dir.chdir(@tempdir)
  @dirs = [@tempdir]
end

Before '@slow' do
  @aruba_timeout_seconds = 90
end

After '@destroy' do |scenario|
  Dir.chdir(@tempdir) do
    `blimpy destroy`
  end
end

After do |scenario|
  Dir.chdir(@cwd)

  unless scenario.failed?
    # NOTE: just having this line here makes me apprehensive
    #FileUtils.rm_rf(@tempdir) unless @tempdir.nil?
  else
    puts "Leaving the tempdir in tact: #{@tempdir}"
  end
end
