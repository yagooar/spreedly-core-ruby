require 'test_helper'

module SpreedlyCore
  module TestCommon
    include TestHelper
    include TestFactory

    def setup
      raise "environment variables for SPREEDLYCORE_API_LOGIN and SPREEDLYCORE_API_SECRET must be set" unless ENV['SPREEDLYCORE_API_LOGIN'] && ENV['SPREEDLYCORE_API_SECRET']

      SpreedlyCore.configure
      unless SpreedlyCore.gateway_token
        gateway = SpreedlyCore::TestGateway.get_or_create
        gateway.use!
      end

      PaymentMethod.reset_additional_required_cc_fields
    end
  end
end