module SpreedlyCore
  class TestGateway < Gateway
    # gets a test gateway, creates if necessary
    def self.get_or_create
      # get the list of gateways and return the first test gateway
      # if none exist, create one
      verify_get("/gateways.xml") do |response|
        response.parsed_response["gateways"].each do |gateway|
          
        end
      end
    end
  end
end