class Task

  attr_accessor :task_logger
  attr_accessor :task_run

  # Rails model compatibility #
  def self.all
    TaskManager.instance.create_all_tasks
  end

  def self.find(name)
    TaskManager.instance.create_task_by_name name
  end

  def self.find_by_name(name)
    TaskManager.instance.create_task_by_name name
  end
  
  def self.model_name
    "task"
  end 

  def self.id
    return self.name
  end
  # End Rails compatibility 

  def to_json
    { :name => name, :description => description}
  end

  def candidates(type="Base")
    candidate_list = []

    eval("Entities::#{type}").all.each do |entity| 
      candidate_list << entity if self.allowed_types.include? entity.class
    end
  candidate_list
  end

  def underscore
    "task"
  end

  def full_path
    __FILE__
  end

  def allowed_types
    []
  end

  def name
    "Generic Task"
  end
  
  def task_name
    name
  end

  def pretty_name
    "Generic Task"
  end
  
  def description
    "This is a generic task"
  end

  #
  # Convenience Method to execute a system command semi-safely
  #
  #  !!!! Don't send anything to this without first whitelisting user input!!! 
  #
  def safe_system(command)
  
    ###      ###
    ### TODO ###
    ###      ###

    if command =~ /(\||\;|\`)/
      raise "Illegal character"
    end

    `#{command}`
  end

  #
  # Convenience method to open a URI
  #
  def open_uri_and_return_content(uri,logger)
    begin

      # Prevent encoding errors
      content = open("#{uri}", :allow_redirections => :safe).read.force_encoding('UTF-8')

    # Lots and lots of things to go wrong... wah wah.
    rescue OpenURI::HTTPError => e
      logger.error "HTTPError - Unable to connect to #{uri}: #{e}"
    rescue Net::HTTPBadResponse => e
      logger.error "HTTPBadResponse-  Unable to connect to #{uri}: #{e}"
    rescue OpenSSL::SSL::SSLError => e
      logger.error "SSLError - Unable to connect to #{uri}: #{e}"
    rescue EOFError => e
      logger.error "EOFError - Unable to connect to #{uri}: #{e}"
    rescue SocketError => e
      logger.error "SocketError - Unable to connect to #{uri}: #{e}"
    rescue RuntimeError => e
      logger.error "RuntimeError - Unable to connect to #{uri}: #{e}"
    rescue SystemCallError => e
      logger.error "SystemCallError - Unable to connect to #{uri}: #{e}"
    rescue ArgumentError => e
      logger.error "Argument Error - #{e}"
    rescue URI::InvalidURIError => e
      logger.error "InvalidURIError - #{uri} #{e}"
    rescue Encoding::InvalidByteSequenceError => e
      logger.error "InvalidByteSequenceError - #{e}"
    rescue Encoding::UndefinedConversionError => e
      logger.error "UndefinedConversionError - {e}"
    end
    
  content
  end

  #
  # Convenience method that makes it easy to create entities from within a task. 
  # Designed to simplify the task api. Do not override.
  #
  # current_entity keeps track of the current entity which we're associating with
  # params are params for creating the new entity
  #  new_entity keeps track of the new entity
  #
  def create_entity(type, params, current_entity=@entity)

    # Let's sanity check the type first. 
    unless Entities::Base.descendants.include?(type)
      raise RuntimeError, "Invalid entity type"
    end

    #
    # Call the create method for this type
    #
    new_entity = type.send(:create, params) 

    #
    # Check for dupes & return right away if this doesn't save a new
    # entity. This should prevent the entity mapping from getting created.
    #    
    if new_entity.save
      @task_logger.good "Created new entity: #{new_entity}"
    else
      @task_logger.log "Could not save entity, are you sure it's valid & doesn't already exist?"
      
      # Attempt to find the entity
      new_entity = find_entity(type, params)
    
      raise RuntimeError, "Unable to find a valid entity: #{type}, #{params}" unless new_entity
    end

    #
    # If we have a new entity, then we should keep track of the information
    # that created this entity
    #
    if current_entity.children.include? new_entity
      @task_logger.log "Skipping association of #{current_entity} and #{new_entity}. It's already a child."
      
      # TOTALLY EXPERIMENTAL
      new_entity.entity_mappings << current_entity
    else
      @task_logger.log "Associating #{current_entity} with #{new_entity} and task run #{@task_run}"
      current_entity.associate_child({:child => new_entity, :task_run => @task_run})
     
      # TOTALLY EXPERIMENTAL
      current_entity.entity_mappings << new_entity
      new_entity.entity_mappings << current_entity
    end
    
  new_entity
  end

  #
  # This method is used to locate a pre-existing entity before we try to save a new 
  # entity. It is called by create_entity in the Task class. The params entity is a 
  # set of things that will be used to create the entity, so it's generally safe to 
  # refer to the most common of parameters for the entity (especially if they're 
  # enforced by validation)
  #
  # takes a type, and a set of params
  #
  # returns the entity if it is found, else false
  #
  # Will raise an error if it doesn't know how to find a type of entity
  #
  # ooh, this is dangerous metamagic. -- would need to be revisited if we do 
  # something weird with the models. for now, it should be sufficent to generally
  # send "name" and special case anything else.
  #
  def find_entity(type, params)

    if type == Entities::ParsableFile
      return Entities::ParsableFile.where({
        :path => params[:path]}).first

    elsif type == Entities::PhysicalLocation
      return Entities::PhysicalLocation.where({
        :latitude => params[:latitude], 
        :longitude => params[:longitude]}).first
      
    else
      if params.has_key? :name
        return type.send(:where, :name => params[:name]).first
      else
        raise "Don't know how to find this entity of type #{type}"
      end
    end
  end

  # 
  # Run the task. Convenience method. Do not override
  #
  def execute(entity, options={}, task_run_set_id)
    
    #
    # Do some logging in the main Tapir log
    # 
    TapirLogger.instance.log "Running task: #{self.name}"
    TapirLogger.instance.log "Entity: #{entity}"
    TapirLogger.instance.log "Options: #{options}"

    #
    # Call the methods to do something with the entities that have been passed into this task.
    #   This also creates the @task_run object which will be used to track this task's results
    #
    self.setup(entity, options)

    #
    # Associate the entity and the task run
    #
    entity.task_runs << @task_run
    entity.save!

    #
    # Keep track of which tasks were run together.
    #
    TapirLogger.instance.log "Associating task run #{@task_run} with set #{task_run_set_id}"
    @task_run.task_run_set = TaskRunSet.find task_run_set_id
    @task_run.save
    
    #
    # Do the work
    #
    self.run

    #
    # Always mop the floor
    #
    self.cleanup 
    
    #
    # Return the log
    #
    @task_run.task_log = @task_logger.text
    @task_run.save
  end
  
  #
  # Convenience method that makes it easy to create entities from within a task. 
  # Designed to simplify the task api. Do not override.
  #
  def create_entity(type, params)

    # for readability
    current_entity = @entity

    # Let's sanity check the type first. 
    unless Entities::Base.descendants.include?(type)
      raise RuntimeError, "Invalid entity type"
    end

    #
    # Call the create method for this type
    #
    new_entity = type.send(:create, params) 

    #
    # Check for dupes & return right away if this doesn't save a new
    # entity. This should prevent the entity mapping from getting created.
    #    
    if new_entity.save
      @task_logger.good "Created new entity: #{new_entity}"
    else
      @task_logger.log "Could not save entity, are you sure it's valid & doesn't already exist?"
      
      # Attempt to find the entity
      new_entity = find_entity(type, params)
    
      raise RuntimeError, "Unable to find a valid entity: #{type}, #{params}" unless new_entity
    end

    #
    # If we have a new entity, then we should keep track of the information
    # that created this entity
    #
    if @entity.children.include? new_entity
      @task_logger.log "Skipping association of #{current_entity} and #{new_entity}. It's already a child."
    else
      @task_logger.log "Associating #{current_entity} with #{new_entity} and task run #{@task_run} with entity mappings"

      #
      # Create a new entity mapping
      #
      entity_mapping = EntityMapping.create(
        :parent_id => current_entity.id,
        :parent_type => current_entity.class.to_s,
        :child_id => new_entity.id,
        :child_type => new_entity.class.to_s,
        :task_run_id => @task_run.id)

      #
      # Add to entity mappings on both sides
      #
      @task_logger.log "Associating #{current_entity} with child entity #{new_entity} through #{entity_mapping}"
      current_entity.entity_mappings << entity_mapping
      current_entity.save

      ## TODO - Oh man. .save! doesnt actually persist the relation. File a mongoid bug.

      @task_logger.log "Associating #{new_entity} with parent entity #{current_entity} through #{entity_mapping}"
      new_entity.entity_mappings << entity_mapping
      new_entity.save
    end

  # return our new entity
  new_entity
  end


  ###
  ### Overridden by subclasses!
  ###
  #
  # Override me
  #
  def setup(entity, options={})
    
    @entity = entity # the entity we're operating on
    @options = options # the options for this task
    @results = [] # temporary collection of all created entitys

    # Create a task run for each one of our entities
    @task_run = TaskRun.create :task_name => self.name, 
      :task_entity_id => @entity.id,
      :task_entity_type => @entity.class.to_s,
      :task_options_hash => @options

    @task_logger = TaskLogger.new(@task_run.id, self.name, true)
     
    #
    # Do a little logging. Do it for the kids.
    #
    @task_logger.log "Setup called."
    @task_logger.log "Task entity: #{@entity}"
    @task_logger.log "Task options: #{@options.inspect}"
  end
  
  #
  # Override me
  #
  def run
    @task_logger.log "Run called." 
  end
  
  #
  # Override me
  #
  def cleanup
    @task_logger.log "Cleanup called." 
  end
  
  def to_s
    "#{name}: #{description}"
  end


end
