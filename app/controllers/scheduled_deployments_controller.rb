class ScheduledDeploymentsController < ApplicationController
  before_filter :load_stage

  def show
    redirect_to :action => :edit
  end

  def new
    @scheduled_deployment = @stage.scheduled_deployments.new
    @task_list = [['All tasks: ', '']] + @stage.list_tasks.collect{|task| [task[:name], task[:name]]}.sort()

  end

  # GET /projects/1/stages/1/scheduled_deployments/1
  def edit
    @scheduled_deployment = @stage.scheduled_deployments.find(params[:id])
    @task_list = [['All tasks: ', '']] + @stage.list_tasks.collect{|task| [task[:name], task[:name]]}.sort()
  end

  # PUT etc 
  def update
    @scheduled_deployment = @stage.scheduled_deployments.find(params[:id])
    @scheduled_deployment.user = current_user
    @scheduled_deployment.status = "pending"

    respond_to do |format|
      if @scheduled_deployment.update_attributes(params[:scheduled_deployment])
        flash[:notice] = 'The scheduled deployment has been updated. You will receive an email shortly'
        format.html { redirect_to project_stage_url(@project, @stage)}
      else
        flash[:notice] = 'You must select a task and insert a valid cron string'
        format.html { redirect_to :action => "edit" }
        format.xml { @scheduled_deployment.errors.to_xml }
      end
    end
  end

  def create
    @scheduled_deployment = @stage.scheduled_deployments.build(params[:scheduled_deployment])
    @scheduled_deployment.user = current_user 
    @scheduled_deployment.status = "new"

    respond_to do |format|
      if @scheduled_deployment.save
        flash[:notice] = 'Scheduled deployment submitted. You will receive an email shortly'
        format.html { redirect_to project_stage_url(@project, @stage) }
        format.xml { head :ok }
      else
        flash[:notice] = 'You must select a task and insert a valid cron string'
        format.html { redirect_to :action => "new" }
        format.xml { render :xml => @scheduled_deployment.errors.to_xml }
      end
    end
  end

  def destroy
    @scheduled_deployment = @stage.scheduled_deployments.find(params[:id])
    @scheduled_deployment.status = "remove"
    @scheduled_deployment.save

    respond_to do |format|
      flash[:notice] = 'The scheduled deployment will be deleted shortly.'
      format.html { redirect_to project_stage_url(@project, @stage) }
      format.xml  { head :ok }
    end
  end

end
