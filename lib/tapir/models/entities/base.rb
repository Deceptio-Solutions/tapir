module Entities
  class Base

    include Mongoid::Document
    include Mongoid::Timestamps
    include Neo4j::ActiveNode

    include TenantAndProjectScoped
    include EntityHelper

    property :age, type: Date
    property :confidence, type: Integer
    property :name, type: String
    property :status, type: String
    property :comment, type: String # Catch-all unstructured data field

    validates_uniqueness_of :name, :scope => [:tenant_id,:project_id,:_type]
    has_many :entity_mappings

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
      TaskRun.where(:task_entity_id => id).all
    end

    def parent_task_runs
      self.entity_mappings.map{ |e| TaskRun.find e.task_run_id }
    end

    def model_name
      self.model_name
    end

    extend ActiveModel::Naming

  end
end