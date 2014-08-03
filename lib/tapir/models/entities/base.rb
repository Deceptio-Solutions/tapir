module Entities
  class Base
    include Mongoid::Document
    include Mongoid::Timestamps

    include TenantAndProjectScoped
    include EntityHelper

    field :age, type: Date
    field :confidence, type: Integer
    field :name, type: String
    field :status, type: String
    field :comment, type: String # Catch-all unstructured data field

    validates_uniqueness_of :name, :scope => [:tenant_id,:project_id,:_type]
    
    has_many :entity_mappings, as: :mappable

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

    def model_name
      self.model_name
    end

    extend ActiveModel::Naming

  end
end