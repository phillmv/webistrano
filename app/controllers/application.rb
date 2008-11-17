class ApplicationController < ActionController::Base
  include BrowserFilters
  include ExceptionNotifiable
  include AuthenticatedSystem
  
  before_filter CASClient::Frameworks::Rails::Filter if WebistranoConfig[:authentication_method] == :cas
  before_filter :login_from_cookie, :login_required
  around_filter :set_timezone

  layout 'application'

  helper :all # include all helpers, all the time
  helper_method :current_stage, :current_project

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery

  protected

  def set_timezone
    # default timezone is UTC
    Time.zone = logged_in? ? ( current_user.time_zone rescue 'UTC'): 'UTC'
    yield
    Time.zone = 'UTC'
  end

  def load_project(id = nil, skip_auth = nil)
    params[:project_id] ||= id
    @project = Project.find(params[:project_id])
    return true if skip_auth
    #nice if refactored
    unless current_user.auth_project(@project)
      flash[:notice] = "You are not allowed to access this project"
      request.env["HTTP_REFERER"] ? (redirect_to :back) : (redirect_to home_url)
      return false
    end
  end

  def load_stage(id = nil)
    params[:stage_id] ||= id

    @stage = Stage.find(params[:stage_id])
    unless current_user.auth_stage(@stage)
      flash[:notice] = "You are not allowed to access this project stage"
      request.env["HTTP_REFERER"] ? (redirect_to :back) : (redirect_to home_url)
      return false
    end
    # stages have a unique id;
    # authorization current works on stages, so check auth before
    # bothering to load_project

    load_project(nil, true)
  end

  def current_stage
    @stage
  end

  def current_project
    @project
  end

  def ensure_admin
    if logged_in? && current_user.admin?
      return true
    else
      flash[:notice] = "Action not allowed"
      redirect_to home_path
      return false
    end
  end

  def check_authorization
    if logged_in? && current_user.is_allowed?(project)
      return true
    else
      flash[:notice] = "Action not allowed"
      redirect_to home_path
      return false
    end
  end

end
