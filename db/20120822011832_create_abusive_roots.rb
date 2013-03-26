class CreateAbusiveRoots < ActiveRecord::Migration
  def self.up
    create_table :abusive_roots do |t|
      t.integer    :id
      t.string     :word
      t.timestamps
    end

    add_index(:abusive_roots, :word, {:unique => true})
  end

  def self.down
    remove_index(:abusive_roots, :word)
    drop_table :abusive_roots
  end
end

