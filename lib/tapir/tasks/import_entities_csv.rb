def name
  "import_entities_csv"
end

def pretty_name
  "Import Entities CSV"
end

def authors
  ['jcran']
end

## Returns a string which describes what this task does
def description
  "This is a task to import entities from a csv."
end

## Returns an array of types that are allowed to call this task
def allowed_types
  [ Entities::ParsableFile,
    Entities::ParsableText ]
end

## Returns an array of valid options and their description/type for this task
def allowed_options
 []
end

def setup(entity, options={})
  super(entity, options)
end

## Default method, subclasses must override this
def run
  super

  if @entity.kind_of? Entities::ParsableText
    text = @entity.text
  else #ParsableFile
    text = open(@entity.uri).read
  end

  # 
  # This task allows you to import a file with the following format: 
  #
  # { "type" : "Entities::EmailAddress", "name" : "test@test.com" }
  #
  # The format is a JSON hash of fields, with a specified type. One 
  # entity / line
  #
  
  # For each line in the file, create an entity
  text.each_line do |json|
    begin
      fields = JSON.load(json)

      # Check to make sure a type was specified
      next unless fields['type']

      # Let's sanity check the type first. 
      next unless Entities::Base.descendants.map{|x| x.to_s}.include?(fields['type'])

      # Okay, we know its a valid type, so go ahead and eval it. 
      type = eval(fields['type'])

      # Create the entity
      create_entity type, fields

    rescue Exception => e
      @task_logger.error "Encountered exception #{e}"
      @task_logger.error "Unable to create entity: #{type}, #{fields}"
      
    end

  end

end

def cleanup
  super
end
