class AddConferenceIdToDivision < ActiveRecord::Migration
  def change
    add_column :divisions, :conference_id, :integer
  end
end
