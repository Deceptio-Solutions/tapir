class EntityMapping
  include Mongoid::Document
  include Mongoid::Timestamps
  include TenantAndProjectScoped

  belongs_to :task_run
  belongs_to :connection, polymorphic: true

  field :parent_id, type: String
  field :parent_type, type: String
  field :child_id, type: String
  field :child_type, type: String
  field :task_run_id, type: String

 # TODO: INDEX!!!
  def get_task_run
    begin
      TaskRun.find(task_run_id)
    rescue Mongoid::Errors::DocumentNotFound => e
      TapirLogger.instance.log "Oops, couldn't find #{child_type}:#{child_id}:\n #{e}"
      nil
    end
  end

  # TODO: INDEX!!!
  def get_child
    TapirLogger.instance.log "Trying to find #{child_type}:#{child_id}"
    begin
      eval "#{child_type}.find(\"#{child_id}\")"
    rescue Mongoid::Errors::DocumentNotFound => e
      TapirLogger.instance.log "Oops, couldn't find #{child_type}:#{child_id}:\n #{e}"
      nil
    end    
  end
  
  # TODO: INDEX!!!
  def get_parent
    TapirLogger.instance.log "Trying to find #{parent_type}:#{parent_id}"
    begin
      eval "#{parent_type}.find(\"#{parent_id}\")"
    rescue Mongoid::Errors::DocumentNotFound => e
      TapirLogger.instance.log "Oops, couldn't find #{parent_type}:#{parent_id}"
      nil
    end
  end

  def to_s
    "#{self.id}: #{parent_type}:#{parent_id} -> #{child_type}:#{child_id} - (#{TaskRun.find task_run.id})"
  end 

end