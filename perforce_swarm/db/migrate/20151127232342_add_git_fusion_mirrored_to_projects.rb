class AddGitFusionMirroredToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :git_fusion_mirrored, :boolean, null: false, default: false

    # ensure that any currently-mirrored projects are marked as such
    execute('UPDATE projects SET git_fusion_mirrored=TRUE WHERE git_fusion_repo is not NULL')
  end
end
