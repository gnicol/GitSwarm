class AddGitFusionRepoToProjects < ActiveRecord::Migration
  def change
    # prior to 2016-07-01, our migrations were not properly recorded as having been applied
    # we have fixed this in engine.rb, but older migrations need the logic below to ensure
    # they aren't applied more than once
    return if column_exists?(:projects, :git_fusion_repo)

    add_column :projects, :git_fusion_repo, :string
  end
end
