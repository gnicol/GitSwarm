class UsersController < ApplicationController
  skip_before_filter :authenticate_user!
  before_filter :set_user
  layout :determine_layout

  def show
    # Projects user can view
    visible_projects = ProjectsFinder.new.execute(current_user)
    authorized_projects_ids = visible_projects.pluck(:id)

    @contributed_projects = Project.where(id: authorized_projects_ids).
      in_group_namespace.includes(:namespace)

    @projects = @user.personal_projects.
      where(id: authorized_projects_ids).includes(:namespace)

    # Collect only groups common for both users
    @groups = @user.groups & GroupsFinder.new.execute(current_user)

    # Get user activity feed for projects common for both users
    @events = @user.recent_events.
      where(project_id: authorized_projects_ids).
      with_associations.limit(30)

    @title = @user.name
    @title_url = user_path(@user)

    respond_to do |format|
      format.html
      format.atom { render layout: false }
    end
  end

  def calendar
    visible_projects = ProjectsFinder.new.execute(current_user)
    calendar = Gitlab::CommitsCalendar.new(visible_projects, @user)
    @timestamps = calendar.timestamps
    @starting_year = calendar.starting_year
    @starting_month = calendar.starting_month

    render 'calendar', layout: false
  end

  def determine_layout
    if current_user
      'navless'
    else
      'public_users'
    end
  end

  private

  def set_user
    @user = User.find_by_username!(params[:username])

    unless current_user || @user.public_profile?
      return authenticate_user!
    end
  end
end
