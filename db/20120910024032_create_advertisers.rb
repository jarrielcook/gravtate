class CreateAdvertisers < ActiveRecord::Migration
  def self.up
    create_table :advertisers do |t|
      t.string :fullname
      t.string :company
      t.string :industry
      t.string :username
      t.string :password
      t.string :email

      t.timestamps
    end
    add_index(:advertisers, :username, {:unique => true})
  end

  def self.down
    remove_index(:advertisers, :username)
    drop_table :advertisers
  end
end
