class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.integer    :id
      t.string     :uid
      t.boolean    :abuser
      t.timestamps
    end
    add_index(:users, :uid, {:unique => true})
  end

  def self.down
    remove_index(:users, :uid)
    drop_table :users
  end
end
