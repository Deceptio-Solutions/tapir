class TaskRunSet

  include Mongoid::Document
  include Mongoid::Timestamps
  include TenantAndProjectScoped

  field :num_tasks, type: Integer
 
  has_many :task_runs
end