class ChangeConfigParameterValueToText < ActiveRecord::Migration
  def self.up
    change_column :configuration_parameters, :value, :text
  end

  def self.down
    change_column :configuration_parameters, :value, :string
  end
end
