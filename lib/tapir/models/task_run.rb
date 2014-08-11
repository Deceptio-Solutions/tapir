class TaskRun
  include Mongoid::Document
  include Mongoid::Timestamps

  include TenantAndProjectScoped

  field :task_name, type: String
  field :task_entity_id, type: String
  field :task_entity_type, type: String
  field :task_options_hash, type: String
  field :task_log, type: String

  has_many :entity_mappings
  belongs_to :completed_tasks, polymorphic: true
  belongs_to :task_run_set

  def to_s
    "#{task_name} #{entity_mappings.first.get_parent if entity_mappings.first} (#{self.entity_mappings.count} children)"
  end

  def entity
    eval "#{task_entity_type}.find(\"#{task_entity_id}\")"
  end

end