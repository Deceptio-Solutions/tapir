class EntityMapping
  include Mongoid::Document
  include Mongoid::Timestamps
  include Neoid::Relationship
      
  include TenantAndProjectScoped
  belongs_to :task_run

  neoidable do |c|
    c.relationship start_node: :entity_mapping, end_node: :entity_mapping, type: :parents
    c.relationship start_node: :entity_mapping, end_node: :entity_mapping, type: :children
  end
 

=begin
  field :child_id, type: String
  field :child_type, type: String
  field :parent_id, type: String
  field :parent_type, type: String
  field :task_run_id, type: String

  index({ child_id: 1, child_type: 1 }, { unique: true })
  index({ parent_id: 1, parent_type: 1 }, { unique: true })

  # TODO: INDEX
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
    "#{self.class}: #{child_type}:#{child_id} <-> #{parent_type}:#{parent_id} - (task_run: #{task_run.id})"
  end 
=end
end