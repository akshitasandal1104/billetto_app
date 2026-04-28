class CreateEventVoteCounts < ActiveRecord::Migration[8.1]
  def change
    create_table :event_vote_counts do |t|
      t.integer :event_id
      t.integer :upvotes
      t.integer :downvotes

      t.timestamps
    end
    add_index :event_vote_counts, :event_id
  end
end
