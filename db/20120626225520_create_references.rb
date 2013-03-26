class CreateReferences < ActiveRecord::Migration
  def self.up
    create_table :references do |t|
      t.integer    :id
      t.integer    :location_id
      t.integer    :tag_id
      t.integer    :count, :default => 1
      t.datetime   :time_block
      t.timestamps
    end

    add_index(:references, [:location_id, :tag_id, :time_block])
  end

  def self.down
    remove_index(:references, [:location_id, :tag_id, :time_block])
    drop_table :references
  end
end
