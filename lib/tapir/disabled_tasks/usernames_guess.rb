def name
  "usernames_guess"
end

def pretty_name
  "Usernames Guess"
end

def authors
  ['jcran']
end

## Returns a string which describes what this task does
def description
  "This task can be used to guess usernames, given a user."
end

## Returns an array of types that are allowed to call this task
def allowed_types
  [Entities::Person]
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

  # TODO - check for dictionary terms?

  ##
  ## John Effing Doe
  ##

  split_name = @entity.name.split(" ")

  #johndoe
  create_entity Entities::Username, {:person => @entity, :name => "#{split_name.first}.#{split_name.last}"}
  
  # john.doe
  create_entity Entities::Username, {:person => @entity, :name => "#{split_name.first}.#{split_name.last}"}

  # john_doe 
  create_entity Entities::Username, {:person => @entity, :name => "#{split_name.first}_#{split_name.last}"}
  
  # jdoe
  create_entity Entities::Username, {:person => @entity, :name => "#{split_name.first.first}#{split_name.last}"}

  # doe
  create_entity Entities::Username, {:person => @entity, :name => "#{split_name.last}"}


end
  
def cleanup
  super
end
