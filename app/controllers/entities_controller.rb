class EntitiesController < ApplicationController

  before_filter :authenticate_user!

  # GET /entities
  # GET /entities.json
  def index

    session["view_types"] = params["type"] if params["type"]
    entities = []
    session["view_types"].each do |type|

      if Entities.const_defined? type
        entities << eval("Entities::#{type}").all 
      end
    end

    # Gather all tasks for our task runner
    @tasks = Task.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: EntitiesDatatable.new(view_context, entities) }
    end
  end

  # GET /entities/1
  # GET /entities/1.json
  def show
    @entity = Entities::Base.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @entity }
    end
  end

  # GET /entities/new
  # GET /entities/new.json
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @entity }
    end
  end

  # GET /entities/1/edit
  def edit
    @entity = Entities::Base.find(params[:id])
  end

  # POST /entities
  # POST /entities.json
  def create

    # interpret the type based on the user's input. 
    type = params[:type]

    # TODO - there has to be a better way to do this
    render action: "new", notice: "invalid entity type." unless get_valid_type_class_names.include?(type)

    @entity = eval("Entities::#{type}").create

    respond_to do |format|
      if @entity.save(:validate => false)
        format.html { render action: "edit", notice: 'entity was successfully created.' }
        format.json { render json: @entity, status: :created, location: @entity }
      else
        format.html { render action: "new", notice: "unable to save entity." }
        format.json { render json: @entity.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /entities/1
  # PUT /entities/1.json
  def update
    @entity = Entities::Base.find(params[:oid])

    respond_to do |format|
      if @entity.update_attributes(params)
        format.html { redirect_to entity_path(@entity), notice: 'Entity was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @entity.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /entities/1
  # DELETE /entities/1.json
  def destroy
    @entity = Entities::Base.find(params[:id])
    @entity.destroy

    respond_to do |format|
      format.html { 
        # This is a hack to handle the delete via the 
        # task_run_sets page specially. We don't want 
        # to always send the user back to the index action
        if request.referer =~ /task_run_sets/
          redirect_to request.referer
        else
          redirect_to entities_url 
        end
      }
      format.json { head :ok }
    end
  end
  
  # Return the valid entity types
  def get_valid_type_class_names
    types = Entities::Base.descendants.map{|x| x.name.split("::").last}
  types.sort_by{ |t| t.downcase }
  end

  private  
    # Return the valid entity types
    def _get_valid_types
      types = Entities::Base.descendants
    end

end
