module Entities
  class Base
    include Mongoid::Document
    include Mongoid::Timestamps

    include TenantAndProjectScoped
    include EntityHelper

    extend ActiveModel::Naming

    field :age, type: Date
    field :confidence, type: Integer
    field :name, type: String
    field :status, type: String
    field :comment, type: String # Catch-all unstructured data field

    validates_uniqueness_of :name, :scope => [:tenant_id,:project_id,:_type]
    
    has_many :entity_mappings, as: :entity_mappable

    def to_s
      "#{entity_type.capitalize}: #{name}"
    end

    def self.descendants
      ObjectSpace.each_object(Class).select { |klass| klass < self }
    end

    # Class method to convert to a path
    def self.underscore
      self.class.to_s.downcase.gsub("::","_")
    end

    def all
      entities = []
      Entities::Base.unscoped.descendants.each do |x|
        x.all.each {|y| entities << y } unless x.all == [] 
      end
      
    entities
    end

    def task_runs
      TapirLogger.instance.log "Finding task runs for #{self}"
      
      all_task_runs = self.entity_mappings.map {|e| TaskRun.find e.task_run_id }

    # An entity mapping is created for every new entity, so we'll need to 
    # pull out the unique task runs from this  
    all_task_runs.uniq
    end

    def model_name
      self.model_name
    end

    ###
    ### Pulled out of entity_helper.rb
    ###

    def to_s
      "#{self.class} #{self.name}"
    end
    
    def entity_type
      self.class.to_s.downcase.split("::").last
    end

    #
    # This method lets you query the available tasks for this entity type
    #
    def tasks
      TapirLogger.instance.log "Getting tasks for #{self}"
      tasks = TaskManager.instance.get_tasks_for(self)
    tasks.sort_by{ |t| t.name.downcase }
    end

    #
    # This method lets you run a task on this entity
    #
    def run_task(task_name, task_run_set_id, options={})
      TapirLogger.instance.log "Asking task manager to queue task #{task_name} run on #{self} with options: #{options} - part of taskrun set: #{task_run_set_id}"
      TaskManager.instance.queue_task_run(task_name, task_run_set_id, self, options)
    end

    #
    # This method lets you find all available children
    #
    def children
      TapirLogger.instance.log "Finding children for #{self}"
      children = []
      self.entity_mappings.each {|mapping| children << mapping.get_child if mapping.child_id }
    children
    end

    #
    # This method lets you find all available parents
    #
    def parents
      TapirLogger.instance.log "Finding parents for #{self}"
      parents = []

      require 'pry'
      binding.pry

      self.entity_mappings.each {|x| parents << x.get_parent if x.child_id == self.id }
    parents
    end

    #
    # This method lets you find all task runs that created this entity
    #
    def parent_task_runs
      TapirLogger.instance.log "Finding task runs for #{self}"
      parent_task_runs = []
      # For each of the associated parents
      self.parents.each do |parent| 
        # go through ech of the parents' entity mappings
        parent.entity_mappings.each do |e| 
          # look for entity mappings where the child is us
          task_run = TaskRun.find(e.task_run_id)
          if e.child_id == self.id 
            if ! parent_task_runs.include? task_run
              parent_task_runs << task_run
            end
          end
        end
      end

    # for each of those parent mappings
    parent_task_runs
    end

    #
    # This method associates a child with this entity
    #
    def associate_child(params)
      # Pull out the relevant parameters
      new_entity = params[:child]
      task_run = params[:task_run]
      
       # And associate the entity as a child through an entity mapping
      TapirLogger.instance.log "Associating #{self} with child entity #{new_entity}"
      _map_child(params)
    end

    def _map_child(params)
      TapirLogger.instance.log "Creating new child mapping #{self} => #{params[:child]}"

      # Create a new entity mapping, unless they happen to be the same object (is that possible?)
      e = EntityMapping.create(
        :parent_id => self.id,
        :parent_type => self.class.to_s,
        :child_id => params[:child].id,
        :child_type => params[:child].class.to_s,
        :task_run_id => params[:task_run].id || nil) unless self.id == params[:child].id

    end

  end
end