class CreateLocations < ActiveRecord::Migration
  def self.up
    create_table :locations do |t|
      t.integer    :id
      t.decimal    :lat, :precision => 5, :scale => 2
      t.decimal    :lon, :precision => 5, :scale => 2
      t.timestamps
    end

    add_index(:locations, [:lat,:lon], {:unique => true})
  end

  def self.down
    remove_index(:locations, [:lat,:lon])
    drop_table :locations
  end
end
