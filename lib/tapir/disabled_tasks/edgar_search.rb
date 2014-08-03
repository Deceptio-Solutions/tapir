# Returns the name of this task.
def name
  "edgar_search"
end

def pretty_name
  "EDGAR Corporation Search"
end

def authors
  ['jcran']
end

# Returns a string which describes this task.
def description
  "This task hits the Corpwatch API and creates an entity for all found entities."
end

# Returns an array of valid types for this task
def allowed_types
  [ Entities::SearchString,
    Entities::Organization ]
end

## Returns an array of valid options and their description/type for this task
def allowed_options
 []
end

def setup(entity, options={})
  super(entity, options)
  self
end

# Default method, subclasses must override this
def run
  super

  # Attach to the corpwatch service & search
  x = Client::Corpwatch::CorpwatchService.new
  corps = x.search @entity.name

  corps.each do |corp|
    # Create a new organization entity & attach a record
    o = create_entity Entities::Organization, { 
      :name => corp.name, 
      :data => corp.to_s
    }
    
    create_entity(Entities::PhysicalLocation, {
      :name => corp.address,
      :address => corp.address, 
      :state => corp.state,
      :country => corp.country }
      )
  end
end

def cleanup
  super
end
