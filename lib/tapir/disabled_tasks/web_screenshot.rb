require 'base64'
require 'timeout'

def name
  "web_screenshot"
end

def pretty_name
  "Web Screenshot"
end

## Returns a string which describes what this task does
def description
  "This takes a screenshot of a website using webdriver"
end

## Returns an array of types that are allowed to call this task
def allowed_types
  [ Entities::DnsRecord, 
    Entities::Host ]
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
  
  begin
    
    #
    # Create a browser opbject if we didn't pass one in
    #
    driver = @options['driver'] || Selenium::WebDriver.for(:firefox)
    
    #
    # Set up a timeout, and a sensible default
    #
    if @options['timeout']
      timeout = Integer.new @options['timeout']
    else
      timeout = 30
    end

    #
    # Allow the user to set a save directory
    #
    if @options['save_directory']
      save_location = "#{@options['save_directory']}/#{@entity.name}.png" 
    else
      save_location = "#{PUBLIC_DIRECTORY}/#{@entity.name}.png"
    end

    browse_location = "http://#{@entity.name}"


    status = Timeout.timeout timeout do
      #
      # Navigate & do the screenshot
      # 
      @task_logger.log "Navigating to & snapshotting #{browse_location}"  
      driver.navigate.to browse_location
      driver.save_screenshot save_location

      create_entity Entities::LocalImage,
        :name => browse_location, 
        :local_path => save_location,
        :remote_path => browse_location        
    end
    
    #
    # Close it up if we didn't pass in a browser
    #
    driver.close unless @options['driver']

  rescue Timeout::Error
    @task_logger.log "Timeout!"
  end
  
end

def cleanup
  super
end
