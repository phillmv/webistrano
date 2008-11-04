class CreateScheduledDeployments < ActiveRecord::Migration
  def self.up
    create_table :scheduled_deployments do |t|
      t.string :task
      t.string :schedule
      t.integer :stage_id
      t.string :status
      t.integer :user_id
      t.datetime :next
      t.integer :job_id

      t.timestamps
    end
  end

  def self.down
    drop_table :scheduled_deployments
  end
end
