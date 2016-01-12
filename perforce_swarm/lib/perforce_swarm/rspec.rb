if ENV['RAILS_ENV'] == 'test'
  require 'rspec/rails'
  require_relative '../../spec/support/test_env'

  # this file helps configure Rspec so that tests in the main application
  # can be skipped by overriding them with a test in the perforce_swarm engine
  #
  # to override a test you must create a new test inside of the engine
  # that meets all of the following criteria:
  #
  # 1) the new test must be in a file that has the same relative filepath
  # to the perforce_swarm/spec folder as the original test has to the spec folder
  # 2) the new test must have the 'override: true' tag applied to it
  # 3) must exist inside of the same structure of nested describe, context, and it
  # blocks with the exact same descriptions for each block

  RSpec.configure do |config|
    # this array will hold strings which represent an overriden test
    # each string is made up of the filepath and the test description
    # of a test that is tagged with the override tag
    overrides = []

    # get the description for a test
    # @param [Hash] metadata - metadata from a rspec test
    # @return [String] -  the full description for the test
    # this return string is made up of the descriptions of
    # the nested it, context, and describe blocks for the test
    # each level of description is joined with a slash (/)
    def test_description(metadata)
      if metadata[:example_group].nil? || metadata[:example_group][:description_args].length == 0
        return metadata[:description_args][0].to_s.strip
      end
      (test_description(metadata[:example_group]) + '/' + metadata[:description_args][0].to_s).strip
    end

    # get the filepath of a test
    # @param [Hash] metadata - metadata from a rspec test
    # @return [String] -  the relative filepath for the test
    # relative to the folder which contains the spec folder
    def test_filepath(metadata)
      metadata[:file_path].gsub(%r{^.*/spec}, './spec')
    end

    # string label used to uniquely identify an overridden test
    # @param [Hash] metadata - metadata from a rspec test
    # @return [String] -  the filepath and the description in one string
    # they are joined with comma (,)
    def override_label(metadata)
      test_filepath(metadata) + ',' + test_description(metadata)
    end

    # before the Rspec suite runs, this will include the
    # extra configuration files we've added in our engine
    config.before(:suite) do
      Dir[Rails.root.join('perforce_swarm/spec/support/**/*.rb')].each { |f| require f }
    end

    # in webmock/rspec, stubs are reset after each run. Set a gloabl stub here for our version updates
    config.before(:each) do
      WebMock.stub_request(:get, %r{https://updates\.perforce\.com/static/GitSwarm/GitSwarm(\-ee)?\.json})
        .to_return(status: 200, body: '{"versions":[]}', headers: {})
    end

    # Clear sidekiq worker jobs
    config.after(:each) do
      Sidekiq::Worker.clear_all
    end

    # Capybara retry:  https://gist.github.com/afn/c04ccfe71d648763b306#gistcomment-1658044
    CAPYBARA_TIMEOUT_RETRIES = 3

    config.around(:each, type: :feature) do |ex|
      example = RSpec.current_example
      CAPYBARA_TIMEOUT_RETRIES.times do
        example.instance_variable_set('@exception', nil)
        __init_memoized
        ex.run
        break unless example.exception.is_a?(Capybara::Poltergeist::TimeoutError)
        puts("\nCapybara::Poltergeist::TimeoutError at #{example.location}\n   Restarting phantomjs and retrying...")
        restart_phantomjs
      end
    end

    def restart_phantomjs
      puts '-> Restarting phantomjs: iterating through capybara sessions...'
      session_pool = Capybara.send('session_pool')
      session_pool.each do |mode, session|
        msg = "  => #{mode} -- "
        driver = session.driver
        if driver.is_a?(Capybara::Poltergeist::Driver)
          msg += 'restarting'
          driver.restart
        else
          msg += "not poltergeist: #{driver.class}"
        end
        puts msg
      end
    end

    # this filter sets up which tests to run
    #
    # it will apply a tag 'main_app' to any test that is not in the engine
    #
    # it will check for the test to be marked as an override
    # if it is an override
    # it will store it's identifier string into the overrides array
    # and return false so that this test is not skipped
    #
    # if it is not tagged as an override it will check the overrides array
    # if the array contains the test's identifier string it will skip the test
    # if the array does not contain it, it will not skip the test
    config.filter_run_excluding file_path: (lambda do |_file_path, metadata|
      metadata[:main_app] = true unless metadata[:file_path].include?('perforce_swarm')
      if metadata.key?(:override) && metadata[:override] == true
        unless overrides.include? override_label(metadata)
          overrides << override_label(metadata)
        end
        return false
      end
      return true if overrides.include? override_label(metadata)
      false
    end)
  end
end
