class AddEventIdToJournals < ActiveRecord::Migration[8.1]
  def change
    add_column :journals, :event_id, :string
  end
end
