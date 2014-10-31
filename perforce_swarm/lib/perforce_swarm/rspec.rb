require 'rspec'

RSpec.configure do |config|

  override_file = 'perforce_swarm/config/override_names'
  skip_count = 0

  def ensure_file(filename)
    unless File.exist?(filename)
      File.open(Rails.root.join(filename), 'w') { |f| f.write('') }
    end
  end

  def in_file?(filename, data)
    lines = File.open(Rails.root.join(filename), 'r').read.split("\n")
    lines.include?(data)
  end

  def unique_add_to_file(filename, data)
    unless in_file?(filename, data)
      File.open(Rails.root.join(filename), 'a') { |f| f.write(data + "\n") }
    end
  end

  def test_description(metadata)
    if metadata[:example_group].nil? || metadata[:example_group][:description_args].length == 0
      return metadata[:description_args][0].to_s.strip
    end
    (test_description(metadata[:example_group]) + '/' + metadata[:description_args][0].to_s).strip
  end

  def test_filepath(metadata)
    metadata[:file_path].gsub(/^.*\/spec/, './spec')
  end

  def override_label(metadata)
    test_filepath(metadata) + ',' + test_description(metadata)
  end

  config.before(:suite) do
    Dir[Rails.root.join('perforce_swarm/spec/support/**/*.rb')].each { |f| require f }
    ensure_file(override_file)
  end

  config.after(:suite) do
    puts "\n#{skip_count} example#{'s' if skip_count > 1} skipped" if skip_count > 0
  end

  config.filter_run_excluding :example_group => lambda { |example_group_meta, metadata|
    return false if metadata.key?(:override) && metadata[:override] == true
    if in_file?(override_file, override_label(metadata))
      skip_count += 1
      return true
    end
    false
  }

  config.around(:each) do |test|
    if test.metadata.key?(:override) && test.metadata[:override] == true
      unique_add_to_file(override_file, override_label(test.metadata))
      test.run
    elsif in_file?(override_file, override_label(test.metadata))
      # skip this test
      skip_count += 1
      print '(S)'
    else
      test.run
    end
  end
  # if !rspec_pathlist.include?(path) || rspec_pathlist[path] == test.metadata[:file_path]
  #   Unfortunately, multiple tests will result in the same path if the test is not described with
  #   an "it" block (this is pretty simple).
  #   We therefore only allow dupes in the same test file.
  #   rspec_pathlist[path] = test.metadata[:file_path]
  # end
end
