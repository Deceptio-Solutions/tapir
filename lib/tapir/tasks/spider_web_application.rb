require 'anemone'

def name
  "spider_web_application"
end

def pretty_name
  "Spider a web application and create web pages"
end

def authors
  ['jcran']
end

## Returns a string which describes what this task does
def description
  "This task uses anemone to spider a web application, creating web pages"
end

## Returns an array of types that are allowed to call this task
def allowed_types
  [Entities::WebApplication]
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

  Anemone.crawl(@entity.name, {:obey_robots => false, :depth_limit => 2} ) do |anemone|
    anemone.on_every_page do |page|
      create_entity(Entities::WebPage, {
        :name => page.url,
        :web_application => @entity,
        :uri => page.url.to_s.encode!('UTF-8', 'UTF-8', :invalid => :replace), #
        :content => page.body.to_s.encode!('UTF-8', 'UTF-8', :invalid => :replace)
      })
    end
  end

end

def cleanup
  super
end
