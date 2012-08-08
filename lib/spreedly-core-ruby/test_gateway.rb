module SpreedlyCore
  class TestGateway < Gateway
    # gets a test gateway, creates if necessary
    def self.get_or_create
      # get the list of gateways and return the first test gateway
      # if none exist, create one
      Gateway.all.each do |g|
        return g if g.gateway_type == "test" && g.redacted == false
      end

      # no test gateway yet, let's create one
      return Gateway.create(:gateway_type => "test")
    end
  end
end
