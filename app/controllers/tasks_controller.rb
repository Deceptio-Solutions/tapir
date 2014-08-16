class TasksController < ApplicationController

  before_filter :authenticate_user!

  # GET /tasks
  # GET /tasks.json
  def index
    @tasks = Task.all
    @tasks.sort_by!{ |t| t.name.downcase }

    @data= { 
      "sEcho" => 0,
      "iTotalRecords" => @tasks.count,
      "iTotalDisplayRecords" => @tasks.count,
      "aaData" =>  @tasks.map do |task|
         ["<a href=\"/tasks/#{task.name}\">#{task.name}</a>","#{task.description}"]
        end
    }

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @data } 
    end
  end

  # GET /tasks/1
  # GET /tasks/1.json
  def show
    
    if params[:type]
      candidate_type = "#{params[:type]}"
      # first check to see if we've got a valid type name
      candidate_type = "Base" unless _get_valid_type_class_names.include? candidate_type
      # and then set the appropriate type
    else
      # otherwise default
      candidate_type = "Base"
    end

    @task = Task.find(params[:id])
    @entities = @task.candidates(candidate_type)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @task }
    end
  end

  # GET /tasks/new
  # GET /tasks/new.json
  def new
    @task = Task.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @task }
    end
  end

  # GET /tasks/1/edit
  def edit
    @task = Task.find(params[:id])
  end

  # POST /tasks
  # POST /tasks.json
  def create
    @task = Task.new(params[:tapir_task])

    respond_to do |format|
      if @task.save
        format.html { redirect_to @task, notice: 'Task was successfully created.' }
        format.json { render json: @task, status: :created, location: @task }
      else
        format.html { render action: "new" }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tasks/1
  # PUT /tasks/1.json
  def update
    @task = Task.find(params[:id])

    respond_to do |format|
      if @task.update_attributes(params[:tapir_task])
        format.html { redirect_to @task, notice: 'Task was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.json
  #def destroy
  #  @task = Task.find(params[:id])
  #  @task.destroy
  #
  #  respond_to do |format|
  #    format.html { redirect_to Tasks_url }
  #    format.json { head :ok }
  #  end
  #end
end
