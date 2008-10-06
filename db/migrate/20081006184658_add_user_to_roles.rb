class AddUserToRoles < ActiveRecord::Migration
  def self.up
    add_column :roles, :user, :string
  end

  def self.down
    remove_column :roles, :user
  end
end
