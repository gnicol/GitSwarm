class AddGitFusionRepoToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :git_fusion_repo, :string, limit: 255
  end
end
