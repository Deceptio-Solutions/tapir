class ProjectsController < ApplicationController

  before_filter :authenticate_user!

  # GET /projects
  # GET /projects.json
  def index
    @projects = Project.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @projects }
    end
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    @project = Project.find(params[:id])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @projects }
    end
  end

  # GET /projects/new
  # GET /projects/new.json
  def new
    @project = Project.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @entity_mapping }
    end
  end

  # GET /projects/1/edit
  def edit
    @project = Project.find(params[:id])
  end

  # POST /projects
  # POST /projects
  def create

    @project = Project.new({
        :tenant => Tenant.current}.merge(params[:project]))

    respond_to do |format|
      if @project.save
       
        # Set a cookie so it's activated 
        cookies.permanent[:project] = @project.name
       
        Project.current = @project

        # Create an initial search string
        e = Entities::SearchString.create(:name => @project.name)
        #e.run_task("google_search")

        # Let the user know
        flash[:notice] = "Project created and activated!"
       
        # Respond
        format.html { redirect_to entities_path, notice: 'Project was successfully created.' }
        format.json { render json: @project, status: :created, location: @project }
      else
        format.html { render action: "new", notice: "Unable to save project." }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /projects/1
  # PUT /projects/1.json
  def update
    @project = Project.find(params[:id])
    respond_to do |format|
      if @project.update_attributes(params[:project])
        format.html { redirect_to project_path(@project), notice: 'Project was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "show" }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  def activate
    @project = Project.find(params[:id])
    
    # Destroy all associated entites
    cookies.permanent[:project] = @project.name

    respond_to do |format|
      format.html { redirect_to projects_url }
      format.json { head :ok }
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project = Project.find(params[:id])
    
    # Destroy all associated entites
    @project_entities = Entities::Base.all.each { |entity| entity.destroy  }

    # Destroy the project
    @project.destroy

    respond_to do |format|
      format.html { redirect_to projects_url }
      format.json { head :ok }
    end
  end



end
