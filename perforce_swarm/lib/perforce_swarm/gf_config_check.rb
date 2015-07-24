require '/opt/gitswarm/embedded/service/gitlab-shell/perforce_swarm/utils.rb'
require '/opt/gitswarm/embedded/service/gitlab-shell/perforce_swarm/git_fusion.rb'
# can we require those in a different way?

module PerforceSwarm
  class GitFusionConfig
    def self.call_configured_instances
      # Get all keys from config, ignore enabled flag
      # probably smart to add a function to filter unnecessary data.
      # Call gf for each instance and save output
      @config = PerforceSwarm::GitlabConfig.new
      @gf_instances = @config.git_fusion.keys if @config.git_fusion_enabled? || []
      @gf_instances.delete('enabled')
      @gf_instances.each do |instance|
        output = PerforceSwarm::GitFusion.run(instance, "info")
        version = output[/Git Fusion\/(\d{4}*)\.(\d{1,2}*)*/] || ""
        display_info(@config.git_fusion[instance]["url"], version) if !output.empty? || display_error(@config.git_fusion[instance]["url"])
      end
    end
  end
end