class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.datetime :event_date
      t.string :user
      t.string :event_type
      t.string :otheruser
      t.string :message

      t.timestamps
    end
  end
end
