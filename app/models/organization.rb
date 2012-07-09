class Organization
  #has_many    :domains
  #has_many    :users
  #has_many    :physical_locations
  #has_many    :hosts, :through => :domains
  #has_many    :net_svcs, :through => :hosts
  #has_many    :web_apps, :through => :net_svcs
  #has_many    :web_forms, :through => :web_apps
  #has_many    :task_runs
  #validates_uniqueness_of :name
  #validates_presence_of :name
  after_save :log

  include ModelHelper

  key :description
  key :created_at, Time
  key :updated_at, Time

  def to_s
    "#{self.class}: #{self.name}"
  end

private
  def log
    TapirLogger.instance.log self.to_s
  end

end
