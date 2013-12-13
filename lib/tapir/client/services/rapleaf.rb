require 'rapleaf_api'

module Client
module Rapleaf
  class ApiClient
    include Client::Web

    attr_accessor :service_name
    
    def initialize
      @service_name = "rapleaf"
      @api = RapleafApi::Api.new(_api_key)
    end

    # This makes a search against the rapportive API. Note that
    # a new session token is currently requested for every call
    def search(email_address)
      result = {}
      begin
        result = @api.query_by_email(email_address)
      rescue Exception => e
        # silently catch errors
      end
    result
    end

    private

      def _api_key 
        Setting.where({:name=>"rapleaf_api"}).first.value 
      end

  end
end
end