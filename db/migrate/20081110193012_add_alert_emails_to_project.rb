class AddAlertEmailsToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :alert_emails, :text
  end

  def self.down
    remove_column :projects, :alert_emails
  end
end
