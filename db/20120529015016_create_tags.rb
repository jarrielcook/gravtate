class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.integer    :id
      t.text       :tag
      t.boolean    :suspect, :default => false
      t.boolean    :abusive, :default => false
      t.timestamps
    end

    add_index(:tags, :tag, {:unique => true})
  end

  def self.down
    remove_index(:tags, :tag)
    drop_table :tags
  end
end
