class Notification < ActionMailer::Base

  @@webistrano_sender_address = 'Webistrano'

  def self.webistrano_sender_address=(val)
    @@webistrano_sender_address = val
  end

  def deployment(deployment, email)
    @subject    = "Deployment of #{deployment.stage.project.name}/#{deployment.stage.name} finished: #{deployment.status}"
    @body       = {:deployment => deployment}
    @recipients = email
    @from       = @@webistrano_sender_address
    @sent_on    = Time.now
    @headers    = {}
  end

  def scheduled_deployment(sdeploy)
    @subject    = "Schedule for #{sdeploy.task} has been #{sdeploy.status}"
    @body       = "This email is to notify you that #{sdeploy.stage.project.name}/#{sdeploy.stage.name}/#{sdeploy.task} has been #{sdeploy.status}. #{ if sdeploy.status == "accepted" then "The next deployment will occur at " + sdeploy.next.to_s + "." end }"
    @recipients = sdeploy.stage.alert_emails
    @from       = @@webistrano_sender_address
    @sent_on    = Time.now
    @headers    = {}
end
end
