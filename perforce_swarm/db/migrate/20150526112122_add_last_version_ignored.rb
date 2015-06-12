class AddLastVersionIgnored < ActiveRecord::Migration
  def change
    add_column :application_settings, :last_version_ignored, :string
  end
end
