class TaskRunSetsController < ApplicationController

  before_filter :authenticate_user!

  # GET /task_run_sets
  # GET /task_run_sets.json
  def index
    @task_run_sets = TaskRunSet.all

    @data= { 
      "sEcho" => 0,
      "iTotalRecords" => @task_run_sets.count,
      "iTotalDisplayRecords" => @task_run_sets.count,
      "aaData" =>  @task_run_sets.map do |task_run_set|

         # Calculate a name for the task run set 
         if task_run_set.task_runs.count > 0
           task_run_name = "#{task_run_set.task_runs.map{|t| t.task_name}.uniq.join(" ")}"
         else
           task_run_name = "*pending*"
         end

         [
          "<a href=\"/task_run_sets/#{task_run_set._id}\">#{task_run_name}</a>",
          "#{task_run_set.task_runs.count}",
          "#{task_run_set.num_tasks}",
          "#{task_run_set.updated_at}"]
      end
    }

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @data }
    end
  end

  # GET /task_run_sets/1
  # GET /task_run_sets/1.json
  def show
    @task_run_set = TaskRunSet.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.js   #{ render :text => "show.js.erb" } # show.js.erb -> http://stackoverflow.com/questions/4016285/rails-3-simple-ajaxy-page-updates
      format.json { render json: @task_run_set }
    end
  end

  # GET /task_run_sets/new
  # GET /task_run_sets/new.json
  def new
    @task_run_set = TaskRunSet.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @task_run_set }
    end
  end

  # GET /task_run_sets/1/edit
  def edit
    @task_run_set = TaskRunSet.find(params[:id])
  end

  # POST /task_run_sets
  # POST /task_run_sets.json
  def create
    @task_run_set = TaskRunSet.new(params[:tapir_task_set])

    respond_to do |format|
      if @task_run_set.save
        format.html { redirect_to @task_run_set, notice: 'Task set was successfully created.' }
        format.json { render json: @task_run_set, status: :created, location: @task_run_set }
      else
        format.html { render action: "new" }
        format.json { render json: @task_run_set.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /task_run_sets/1
  # PUT /task_run_sets/1.json
  def update
    @task_run_set = TaskRunSet.find(params[:id])

    respond_to do |format|
      if @task_run_set.update_attributes(params[:tapir_task_set])
        format.html { redirect_to @task_run_set, notice: 'Task set was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @task_run_set.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /task_run_sets/1
  # DELETE /task_run_sets/1.json
  def destroy
    @task_run_set = TaskRunSet.find(params[:id])
    @task_run_set.destroy

    respond_to do |format|
      format.html { redirect_to task_run_sets_url }
      format.json { head :no_content }
    end
  end
  
  def run
    #
    # Get our params
    #
    entity_set = params[:entities]
    task_name = params[:task_name]
    options = params[:options] || {}
    
    # Create the task run set
    task_run_set = TaskRunSet.new
    task_run_set.num_tasks = entity_set.count
    task_run_set.save
    
    #
    # If we don't have reasonable input, return
    #
    # TODO - this is currently broken - how to send back to the 
    # previous page?
    redirect_to :action => "show" unless task_name
    redirect_to :action => "show" unless entity_set

    #
    # Create the entities based on the params
    #
    entities = []
    entity_set.each do |key, value|

        # Convert the parameter to a class and create an object
        # 
        # Example: 
        #  - entity_set - {"Entities::DnsRecord#5143ddc9ad19763c1d000004"=>"on"}
        #  - entity.titleize.gsub(" ","").gsub("/","::") - "Entities::DnsRecord"
        #
        entity_type = key.split("#").first
        entity_id = key.split("#").last
        task_run_set_id = task_run_set.id.to_s

        # Get the current tenant / project
        tenant_id = Tenant.current.id.to_s
        project_id = Project.current.id.to_s
        
        # Run the task on each entity with the TaskRunner Worker
        if Rails.env == "production"
          Resque.enqueue(TaskRunner, 
            tenant_id,
            project_id,
            entity_id, 
            entity_type, 
            task_name, 
            task_run_set_id, 
            options)
        else
          # In development mode, don't use resque
          TaskRunner.perform(
            tenant_id,
            project_id,
            entity_id, 
            entity_type, 
            task_name, 
            task_run_set_id, 
            options)
        end

    end
    
    redirect_to task_run_set_path task_run_set.id
  end
  
end
