if ENV['RAILS_ENV'] != 'production'
  require 'rspec'
  Dir[Rails.root.join('perforce_swarm/spec/support/**/*.rb')].each { |f| require f }

  RSpec.configure do |config|
    config.before(:suite) do
      PerforceTestEnv.init
    end

    config.include PerforceTestEnv

    def testdescription(metadata)
      if metadata[:example_group].nil? || metadata[:example_group][:description_args].length == 0
        return metadata[:description_args][0].to_s
      else
        return testdescription(metadata[:example_group]) + '/' + metadata[:description_args][0].to_s
      end
    end

    $rspec_pathlist = Hash.new

    config.around(:each) do |test|
      path = test.metadata[:file_path].gsub(/^.*\/spec/, './spec') + ',' + testdescription(test.metadata)
      if !$rspec_pathlist.include?(path) || $rspec_pathlist[path] == test.metadata[:file_path]
        # Unfortunately, multiple tests will result in the same path if the test is not described with
        # an "it" block (this is pretty simple).
        # We therefore only allow dupes in the same test file.
        $rspec_pathlist[path] = test.metadata[:file_path]
        test.run
      end
    end
  end
end
