module ApplicationHelper


  # Recursively find children
  def render_children(entity, result = "", depth=0)

    # Base case 
    if entity.children.empty?
      # Base case - Close up the upper-lists
      return result
    elsif depth > 0
      return result
    else
      depth = depth + 1
    end
    
    entity.children.each do |x|
      result << print_result(x, depth)
      next if x.children.include? entity
      render_children(x, result, depth) 
    end

  result 
  end

  # Recursively find parents
  def render_parents(entity, result = "", depth=0)

    #Base case
    if entity.parents.empty?
      # Base case - Close up the upper-lists
      return result
    elsif depth > 0
      return result
    else
      depth = depth + 1
    end

    entity.parents.each do |x|
      # Prevent loops
      next if x.parents.include? entity

      # Print this parent at the beginning of the string
      result.prepend "#{print_result(x, depth)}"      

      # Recurse on the parent
      render_parents(x, result, depth)

    end
    result
  end

  def print_result(entity, depth)
    # << " (#{item.task_runs.where(:task_entity_id => item.id).first}) " 
    "<li>#{link_to(entity, entity_path(entity))} (Distance: #{depth})</li>"
  end

  # Return the valid entity types
  def get_valid_type_class_names
    types = Entities::Base.descendants.map{|x| x.name.split("::").last}
  types.sort_by{ |t| t.downcase }
  end

  private  
    # Return the valid entity types
    def _get_valid_types
      types = Entities::Base.descendants
    end

end
