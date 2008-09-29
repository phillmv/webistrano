class CreateStagesUsersTable < ActiveRecord::Migration
  def self.up
    create_table :stages_users, :id => false do |t|
      t.integer :user_id, :null => false
      t.integer :stage_id, :null => false
    end
  end

  def self.down
    drop_table :stages_users
  end
end
