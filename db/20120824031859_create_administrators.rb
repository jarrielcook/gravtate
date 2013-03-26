class CreateAdministrators < ActiveRecord::Migration
  def self.up
    create_table :administrators do |t|
      t.string :fullname
      t.string :username
      t.string :password
      t.string :email

      t.timestamps
    end
    add_index(:administrators, :username, {:unique => true})
  end

  def self.down
    remove_index(:administrators, :username)
    drop_table :administrators
  end
end
