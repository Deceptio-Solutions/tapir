#http://www.cloudspace.com/blog/2009/02/16/decoding-gps-latitude-and-longitude-from-exif-in-ruby/

require 'exifr'

def name
  "twitpic_photo_locations"
end

# Returns a string which describes what this task does
def description
  "This task pulls down photos for a specified users. It greps the photo data for location info."
end

# Returns an array of types that are allowed to call this task
def allowed_types
  [Tapir::Entities::User]
end

## Returns an array of valid options and their description/type for this task
def allowed_options
 []
end

def setup(entity, options={})
  super(entity, options)
end

# Default method, subclasses must override this
def run
  super

  x = Tapir::Client::TwitPic::TwitPicScraper.new
  @entity.usernames.each do |username|
    photos = x.search_by_user "#{username}"
      
    photos.each do |photo|

      begin
        # Analyze the photo
        pic_data = EXIFR::JPEG.new(photo.local_path) #/tmp/twitpic_file_35193:

        if pic_data.gps_latitude && pic_data.gps_longitude
          @task_logger.log_good "Parsing exif data!"
          lat = pic_data.gps_latitude[0].to_f + (pic_data.gps_latitude[1].to_f / 60) + (pic_data.gps_latitude[2].to_f / 3600)
          long = pic_data.gps_longitude[0].to_f + (pic_data.gps_longitude[1].to_f / 60) + (pic_data.gps_longitude[2].to_f / 3600)
          if pic_data.gps_longitude_ref && pic_data.gps_latitude_ref
            long = long * -1 if pic_data.gps_longitude_ref == "W"   # (W is -, E is +)
            lat = lat * -1 if pic_data.gps_latitude_ref == "S"      # (N is +, S is -)
          else
            @task_logger.log "no gps_latitude_ref / gps_longitude_ref. not adjusting"
          end
          
          #
          # Don't create them if they're useless
          #
          unless lat == 0 and long == 0
            create_entity(PhysicalLocation, {:latitude => "#{lat}",  :longitude => "#{long}"})
          end
          
        else
          @task_logger.log "no gps_latitude / gps_longitude. no exif data to parse"
        end
      rescue EXIFR::MalformedJPEG => e
        @task_logger.log_error "Unable to parse, malformed jpg"
      end

      create_entity Image, 
        :local_path => photo.local_path,
        :remote_path => photo.remote_path, 
        :description => "twitpic image"
    end
  end
end

def cleanup
  super
end
