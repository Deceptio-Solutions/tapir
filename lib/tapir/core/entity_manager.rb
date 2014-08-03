require 'singleton'

class EntityManager

  include Singleton

  #
  # This method will find all children for a particular entity
  #
  def find_children(id, type)
    all_mapped_children = EntityMapping.where(:parent_id => id)

    children = []
    
    #
    # Here, we check to see if we just have a single entity mapping
    #
    if all_mapped_children.kind_of? EntityMapping
      children << all_mapped_children
    else

      #
      # Because we have to account for missing parents, this is 
      # pretty careful about what get returned from this function
      #
      all_mapped_children.each do |mapping|
        child = mapping.get_child
        children << child if child
      end
    end

  children
  end
  
  #
  # This method will find all parents for a particular entity
  #
  def find_parents(id, type)
    all_mapped_parents = EntityMapping.where(:child_id => id)
    parents = []
    #
    # Here, we check to see if we just have a single entity mapping
    #
    if all_mapped_parents.kind_of? EntityMapping
      parents << all_mapped_parents.get_parent
    else
      #
      # Because we have to account for missing parents, this is 
      # pretty careful about what get returns from this function
      #
      all_mapped_parents.each do |mapping|
        parent = mapping.get_parent
        parents << parent if parent 
      end
    end
  parents
  end
  
  #
  # This function is much the same as the find_parents and find_children functions
  #
  def find_task_runs(id, type)
      all_mapped_parents = EntityMapping.all(
          :conditions => {  :child_id => id,
                            :child_type => type})
    task_runs = []
    if all_mapped_parents.kind_of? EntityMapping
      task_runs << all_mapped_parents.get_task_run
    else
      all_mapped_parents.each do |mapping|
        task_run = mapping.get_task_run
        task_runs << task_run if task_run
      end
    end
  task_runs
  end
  
end