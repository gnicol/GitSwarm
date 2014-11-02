require 'rspec'

RSpec.configure do |config|

  override_file = 'perforce_swarm/config/override_names'

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

  unless config.files_to_run.any? { |path| path.include?('perforce_swarm') }
    p 'WARNING: Running the main test without the Swarm overides.'
    p 'To include the overides add the perforce_swarm/spec filepath and the main_app and override tags'
    p 'eg: rspec -t override -t main_app spec perforce_swarm/spec'
  end

  config.filter_run_excluding example_group: (lambda do |_example_group_meta, metadata|
    metadata[:main_app] = true unless metadata[:file_path].include?('perforce_swarm')
    return false if metadata.key?(:override) && metadata[:override] == true
    ensure_file(override_file)
    in_file?(override_file, override_label(metadata))
  end)

  config.around(:each) do |test|
    if test.metadata.key?(:override) && test.metadata[:override] == true
      unique_add_to_file(override_file, override_label(test.metadata))
    end
    test.run
  end
end
