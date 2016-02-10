class Explore::ProjectsController < Explore::ApplicationController
  def index
    @projects = ProjectsFinder.new.execute(current_user)
    @tags = @projects.tags_on(:tags)
    @projects = @projects.tagged_with(params[:tag]) if params[:tag].present?
    @projects = @projects.where(visibility_level: params[:visibility_level]) if params[:visibility_level].present?
    @projects = @projects.non_archived
    @projects = @projects.search(params[:search]) if params[:search].present?
    @projects = @projects.search(params[:filter_projects]) if params[:filter_projects].present?
    @projects = @projects.sort(@sort = params[:sort])
    @projects = @projects.includes(:namespace).page(params[:page]).per(PER_PAGE) if params[:filter_projects].blank?

    respond_to do |format|
      format.html
      format.json do
        render json: {
          html: view_to_html_string("dashboard/projects/_projects", locals: { projects: @projects })
        }
      end
    end
  end

  def trending
    @projects = TrendingProjectsFinder.new.execute(current_user)
    @projects = @projects.non_archived
    @projects = @projects.search(params[:filter_projects]) if params[:filter_projects].present?
    @projects = @projects.page(params[:page]).per(PER_PAGE) if params[:filter_projects].blank?

    respond_to do |format|
      format.html
      format.json do
        render json: {
          html: view_to_html_string("dashboard/projects/_projects", locals: { projects: @projects })
        }
      end
    end
  end

  def starred
    @projects = ProjectsFinder.new.execute(current_user)
    @projects = @projects.search(params[:filter_projects]) if params[:filter_projects].present?
    @projects = @projects.reorder('star_count DESC')
    @projects = @projects.page(params[:page]).per(PER_PAGE) if params[:filter_projects].blank?

    respond_to do |format|
      format.html
      format.json do
        render json: {
          html: view_to_html_string("dashboard/projects/_projects", locals: { projects: @projects })
        }
      end
    end
  end
end
