require 'test_helper'

module SpreedlyCore
  module TestCommon
    include TestHelper
    include TestFactory

    def setup
      raise "environment variables for SPREEDLYCORE_ENVIRONMENT_KEY and SPREEDLYCORE_ACCESS_SECRET must be set" unless ENV['SPREEDLYCORE_ENVIRONMENT_KEY'] && ENV['SPREEDLYCORE_ACCESS_SECRET']

      SpreedlyCore.configure
      unless SpreedlyCore.gateway_token
        gateway = SpreedlyCore::TestGateway.get_or_create
        gateway.use!
      end

      PaymentMethod.reset_additional_required_cc_fields
    end
  end
end
