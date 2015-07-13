class AddGitFusionRepoToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :git_fusion_repo, :string
  end
end
