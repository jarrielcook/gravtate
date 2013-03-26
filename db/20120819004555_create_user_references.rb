class CreateUserReferences < ActiveRecord::Migration
  def self.up
    create_table :user_references do |t|
      t.integer    :id
      t.integer    :user_id
      t.integer    :reference_id
      t.timestamps
    end
    add_index(:user_references, [:user_id, :reference_id])
  end

  def self.down
    remove_index(:user_references, [:user_id, :reference_id])
    drop_table :user_references
  end
end
