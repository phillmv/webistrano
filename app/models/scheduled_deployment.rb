class ScheduledDeployment < ActiveRecord::Base
  belongs_to :user
  belongs_to :stage
  validates_presence_of :user
  validates_presence_of :schedule
  validates_presence_of :task

  protected
  def validate
    errors.add("schedule", "Not a valid cron schedule") unless self.schedule.match ".+ .+ .+ .+ .+"
  end

end
