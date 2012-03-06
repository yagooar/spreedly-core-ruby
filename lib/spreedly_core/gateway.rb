module SpreedlyCore
  class Gateway < Base
    attr_reader(:name, :gateway_type, :auth_modes, :supports_capture,
                :supports_authorize, :supports_purchase, :supports_void,
                :supports_credit, :redacted)

    # returns an array of Gateway which are supported
    def self.supported_gateways
      verify_options("/gateways.xml") do |response|
        response.parsed_response["gateways"]["gateway"].map{|h| new(h) }
      end
    end

    def initialize(attrs={})
      attrs.merge!(attrs.delete("characteristics") || {})
      super(attrs)
    end
  end
end
