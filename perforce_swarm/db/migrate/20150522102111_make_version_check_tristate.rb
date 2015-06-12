class MakeVersionCheckTristate < ActiveRecord::Migration
  def change
    change_column_default :application_settings, :version_check_enabled, nil
  end
end
