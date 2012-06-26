class EntityMappingsController < ApplicationController
  # GET /entity_mappings
  # GET /entity_mappings.json
  def index
    @entity_mappings = EntityMapping.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @entity_mappings }
    end
  end

  # GET /entity_mappings/1
  # GET /entity_mappings/1.json
  def show
    @entity_mapping = EntityMapping.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @entity_mapping }
    end
  end

  # GET /entity_mappings/new
  # GET /entity_mappings/new.json
  def new
    @entity_mapping = EntityMapping.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @entity_mapping }
    end
  end

  # GET /entity_mappings/1/edit
  def edit
    @entity_mapping = EntityMapping.find(params[:id])
  end

  # POST /entity_mappings
  # POST /entity_mappings.json
  def create
    @entity_mapping = EntityMapping.new(params[:entity_mapping])

    respond_to do |format|
      if @entity_mapping.save
        format.html { redirect_to @entity_mapping, notice: 'Entity mapping was successfully created.' }
        format.json { render json: @entity_mapping, status: :created, location: @entity_mapping }
      else
        format.html { render action: "new" }
        format.json { render json: @entity_mapping.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /entity_mappings/1
  # PUT /entity_mappings/1.json
  def update
    @entity_mapping = EntityMapping.find(params[:id])

    respond_to do |format|
      if @entity_mapping.update_attributes(params[:entity_mapping])
        format.html { redirect_to @entity_mapping, notice: 'Entity mapping was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @entity_mapping.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /entity_mappings/1
  # DELETE /entity_mappings/1.json
  def destroy
    @entity_mapping = EntityMapping.find(params[:id])
    @entity_mapping.destroy

    respond_to do |format|
      format.html { redirect_to entity_mappings_url }
      format.json { head :ok }
    end
  end
end
