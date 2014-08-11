require 'singleton'
class TaskManager
  include Singleton

  attr_accessor :tasks
  attr_accessor :tasks_dir
  
  def initialize(path=nil)
    @tasks_dir = path || File.join(File.dirname(__FILE__), "..", "tasks")
    @task_files = []
    @task_objects = []
  end

  def create_all_tasks
    to_return = []
    @task_objects.each {|t| to_return << t.clone}
  to_return
  end

  # Called when we need an instance of the task. Used by the task.
  def create_task_by_name(task_name)
    @task_objects.each do |t|
      return t.clone if t.name == task_name
    end
    raise "Unknown Task!"  # couldn't find it. boo.
  end
  # 
  # This method allows us to reload our tasks
  #
  def reload_tasks(dir=@tasks_dir)
    @task_files = []
    load_tasks(dir)
  end
  
  # 
  # This method loads our task files from disk
  #
  def load_tasks(dir=@tasks_dir)
    @task_files = []
    Dir.entries(dir).each do |entry| 
      #
      # Check for obvious directories
      #
      if !(entry =~ /^\./)
        #
        # Make sure it's a file
        #
        if File.file? dir + "/" + entry 
          #
          # Toss it in our array
          #
          @task_files << dir + "/" + entry 
        end
      end
    end
    
    #
    # For each of our identified task files...
    #
    @task_files.each do |task_file|
      #
      # Create a new task and eval our task into it
      #
      TapirLogger.instance.log "Evaluating task: #{task_file}"
      t = Task.new
      t.instance_eval(File.open(task_file, "r").read)

      #
      # Add it to our task listing
      #
      @task_objects << t
    end
  end
  
  #
  # Given an entity, return all tasks that can operate on that entity 
  #
  def get_tasks_for(entity)
    tasks_for_type = []

    @task_objects.each do |task|
      if task.allowed_types.include?(entity.class)
        tasks_for_type << task.clone
      end
    end

    tasks_for_type
  end

  # This method will be called by the entitys 
  def queue_task_run(task_name, task_run_set_id, entity, options)

    # Make note of the fact that we're shipping this off to the queue
    TapirLogger.instance.log "Task manager queueing task: #{task_name} for entity #{entity} with options #{options}"
    
    # Create the task 
    task = create_task_by_name(task_name)
    
    # CURRENTLY NOT THREADED!
    task.execute(entity, options, task_run_set_id)
  end
end