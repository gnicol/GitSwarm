class AddGitFusionMirroredToProjects < ActiveRecord::Migration
  def change
    # prior to 2016-07-01, our migrations were not properly recorded as having been applied
    # we have fixed this in engine.rb, but older migrations need the logic below to ensure
    # they aren't applied more than once
    return if column_exists?(:projects, :git_fusion_mirrored)

    add_column :projects, :git_fusion_mirrored, :boolean, null: false, default: false

    # ensure that any currently-mirrored projects are marked as such
    execute('UPDATE projects SET git_fusion_mirrored=TRUE WHERE git_fusion_repo is not NULL')
  end
end
