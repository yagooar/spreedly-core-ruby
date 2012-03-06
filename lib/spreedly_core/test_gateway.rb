module SpreedlyCore
  class TestGateway < Gateway
    # gets a test gateway, creates if necessary
    def self.get_or_create
      # get the list of gateways and return the first test gateway
      # if none exist, create one
      verify_get("/gateways.xml") do |response|
        response.parsed_response["gateways"]["gateway"].each do |gateway|
          g = new gateway
          return g if g.gateway_type == "test" && g.redacted == false
        end
      end

      # no test gateway yet, let's create one
      opts = {
        :headers => {"Content-Type" => "application/xml"},
        :body => '<gateway><gateway_type>test</gateway_type></gateway>'
      }

      verify_post("/gateways.xml", opts) do |response|
        return new response.parsed_response["gateway"]
      end

      # HTTP 724
      return nil
    end
  end
end