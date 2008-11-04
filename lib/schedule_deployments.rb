#!/usr/bin/env ruby 
require File.dirname(__FILE__) + '/../config/environment.rb'
$: << File.expand_path(File.dirname(__FILE__) + "/../vendor/plugins/rufus-scheduler-1.0.11")
require 'rufus/scheduler'
require 'ruby-debug'

@logger = Logger.new("#{RAILS_ROOT}/log/scheduler.#{RAILS_ENV}.log")

@scheduler = Rufus::Scheduler.start_new

def schedule(sdeploy)
  @logger.info "adding #{sdeploy.task} method"
  begin

    job = @scheduler.schedule(sdeploy.schedule,  :tags => sdeploy.id, :offset => ActiveSupport::TimeZone.new(sdeploy.user.time_zone).utc_offset ) { 
      |job_id, at, params|
      @logger.warn "executing scheduled task #{sdeploy.task}"

      deployment = sdeploy.stage.deployments.new
      deployment.task = sdeploy.task
      deployment.description = "Scheduled deployment"
      deployment.user = sdeploy.user

      begin
        deployment.save!
        @logger.info "about to deploy"
        sdeploy.next = @scheduler.get_job(job_id).next_time
        sdeploy.save
        puts "deploy after this one will occur at #{@scheduler.get_job(job_id).next_time}"
        deployment.deploy_in_background!
      rescue Exception => e
        @logger.warn e
        sdeploy.status = "deployment failure"
        sdeploy.save
        @scheduler.unschedule(sdeploy)
      end

    }
    sdeploy.status = "accepted"
    sdeploy.next = job.next_time
    puts "just scheduled a new job to run at #{ sdeploy.next }"
    puts "this is how it will get formatted: #{ sdeploy.next.strftime "%H:%M %b %d %Y"}"

#    @logger.warn "size of thingy #{@scheduler.find_jobs(sdeploy.id).size}"
#    sdeploy.next = @scheduler.get_job(job_id).next_time
    sdeploy.save
    puts "this is how it will get formatted: #{ sdeploy.next.strftime "%H:%M %b %d %Y"}"
  rescue Exception => e
    @logger.warn e
    sdeploy.status = "rejected"
    sdeploy.save
  end
  Notification.deliver_scheduled_deployment(sdeploy)
end


def unschedule(sdeploy)
  @scheduler.find_jobs(sdeploy.id).each { |j| 
    @logger.info "unscheduling a job #{sdeploy.task}" 
    j.unschedule
  }
end

#startup
begin 
  @logger.info "rescheduling previously accepted schedules, if any"

  ScheduledDeployment.find(:all, 
                           :conditions => { :status => "accepted" }).each { |s|
    schedule(s) 
  }
rescue Exception => e
  @logger.warn e
end

puts "size of schedules #{@scheduler.cron_job_count}"
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

  sleep 5
end
