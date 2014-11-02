require 'rspec'

RSpec.configure do |config|

  overrides = []

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
  end

  unless config.files_to_run.any? { |path| path.include?('perforce_swarm') }
    p 'WARNING: Running the main test without the Swarm overrides.'
    p 'To include the overrides add the perforce_swarm/spec filepath and the main_app and override tags'
    p 'eg: rspec -t override -t main_app spec perforce_swarm/spec'
  end

  config.filter_run_excluding example_group: (lambda do |_example_group_meta, metadata|
    metadata[:main_app] = true unless metadata[:file_path].include?('perforce_swarm')
    if metadata.key?(:override) && metadata[:override] == true
      unless overrides.include? override_label(metadata)
        overrides << override_label(metadata)
      end
      return false
    end
    if overrides.include? override_label(metadata)
      puts "overrides DID include: #{override_label(metadata)}"
      return true
    end
    puts "overrides did not include: #{override_label(metadata)}"
    puts "#{overrides.inspect}"
    false
  end)

  config.around(:each) do |test|
    if test.metadata.key?(:override) && test.metadata[:override] == true
      unless overrides.include? override_label(test.metadata)
        puts "adding to overrides #{override_label(test.metadata)}"
        puts "current array: #{overrides.inspect}"
        overrides << override_label(test.metadata)
      end
    end
    test.run
  end
end
