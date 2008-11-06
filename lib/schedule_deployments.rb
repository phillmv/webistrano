#!/usr/bin/env ruby 

ENV['RAILS_ENV'] = ARGV[0] || 'development'

require File.dirname(__FILE__) + '/../config/environment.rb'
require 'rufus/scheduler'

@logger = Logger.new("#{RAILS_ROOT}/log/scheduler.#{RAILS_ENV}.log")

@scheduler = Rufus::Scheduler.start_new

def schedule(sdeploy, email = nil)
  @logger.info "\n#{sdeploy.user.login} is scheduling #{sdeploy.task} on #{sdeploy.schedule}"
  begin

    # Webistrano is running Time.zone = "UTC"
    tz_offset = ActiveSupport::TimeZone.new(sdeploy.user.time_zone).utc_offset

    job = @scheduler.schedule(sdeploy.schedule,  :tags => sdeploy.id, :tz_offset => tz_offset) { 
      |job_id, at, params|
      @logger.warn "#{Time.now} Executing #{sdeploy.user.login}'s #{sdeploy.task}"

      # new deployment house keeping
      deployment = sdeploy.stage.deployments.new
      deployment.task = sdeploy.task
      deployment.description = "Deployment scheduled on #{sdeploy.updated_at.in_time_zone sdeploy.user.time_zone}"
      deployment.user = sdeploy.user

      begin
        deployment.save!
        @logger.info "about to deploy"
        sdeploy.next = @scheduler.get_job(job_id).next_time 
        sdeploy.save
        deployment.deploy_in_background!
      rescue Exception => e
        @logger.warn e
        sdeploy.status = "failed"
        sdeploy.save
        @scheduler.get_job(job_id).unschedule
        Notification.deliver_scheduled_deployment(sdeploy)
      end
    }

    sdeploy.status = "accepted"
    sdeploy.next = job.next_time
    sdeploy.save
  rescue Exception => e
    @logger.warn e
    sdeploy.status = "rejected"
    sdeploy.save
  end
  Notification.deliver_scheduled_deployment(sdeploy) unless email
end


def unschedule(sdeploy)
  @scheduler.find_jobs(sdeploy.id).each { |j| 
    @logger.info "unscheduling a job #{sdeploy.task}" 
    j.unschedule
  }
end

#startup
begin 
  @logger.info "\n\n******\nStarting #{Time.now}\nRescheduling previously accepted schedules, if any"

  ScheduledDeployment.find(:all, 
                           :conditions => { :status => "accepted" }).each { |s|
    schedule(s, true) 
  }
rescue Exception => e
  # what can we do, really?
  @logger.warn e
end

@logger.info "starting loop"

loop do
  # do we have new things to schedule?

  begin
    ScheduledDeployment.find(:all, 
                             :conditions => { :status => "new" }).each { |s| 
      schedule(s) 
    }

    ScheduledDeployment.find(:all, 
                             :conditions => { :status => "pending" }).each { |s| 
      unschedule(s)
      schedule(s)
    }

    ScheduledDeployment.find(:all, 
                             :conditions => { :status => "remove" }).each { |s| 
      unschedule(s)
      s.destroy
    }
  rescue Exception => e
    @logger.warn e
  end
  sleep 10
end
