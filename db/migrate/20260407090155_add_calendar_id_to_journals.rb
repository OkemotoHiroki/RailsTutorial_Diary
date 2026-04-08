class AddCalendarIdToJournals < ActiveRecord::Migration[8.1]
  def change
    add_column :journals, :calendar_id, :string
  end
end
