class AddSourceControlType < ActiveRecord::Migration
  def change
	change_table :projects do |t|
		t.string :source_control_type, :default=>"perforce"
	end
  end
end
