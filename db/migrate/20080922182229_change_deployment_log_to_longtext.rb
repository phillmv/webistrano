class ChangeDeploymentLogToLongtext < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE deployments MODIFY log LONGTEXT" if ActiveRecord::Base::connection.adapter_name == "MySQL"
  end

  def self.down
    execute "ALTER TABLE deployments MODIFY log TEXT" if endActiveRecord::Base::connection.adapter_name == "MySQL"
  end
end
