class CreateJournals < ActiveRecord::Migration[8.1]
  def change
    create_table :journals do |t|
      t.date :date
      t.string :title
      t.text :content

      t.timestamps
    end
  end
end
