require 'test_helper'

module SpreedlyCore
  class ConfigureTest < Test::Unit::TestCase

    def test_configure
      old_verbose, $VERBOSE = $VERBOSE, nil

      old_environment_key = ENV['SPREEDLYCORE_ENVIRONMENT_KEY']
      old_access_secret = ENV['SPREEDLYCORE_ACCESS_SECRET']
      old_gateway_token = ENV['SPREEDLYCORE_GATEWAY_TOKEN']
      ENV['SPREEDLYCORE_ENVIRONMENT_KEY'] = nil
      ENV['SPREEDLYCORE_ACCESS_SECRET'] = nil
      ENV['SPREEDLYCORE_GATEWAY_TOKEN'] = nil

      assert_nothing_raised ArgumentError do
        SpreedlyCore.configure :environment_key => "test",
                               :access_secret => "secret",
                               :gateway_token => "token"
      end

      assert_raises ArgumentError do
        SpreedlyCore.configure
      end

      ENV['SPREEDLYCORE_ENVIRONMENT_KEY'] = old_environment_key
      ENV['SPREEDLYCORE_ACCESS_SECRET'] = old_access_secret
      ENV['SPREEDLYCORE_GATEWAY_TOKEN'] = 'any_value'

      SpreedlyCore.gateway_token = nil
      assert_nothing_raised ArgumentError do
        SpreedlyCore.configure
      end
      assert_not_nil SpreedlyCore.gateway_token

      ENV['SPREEDLYCORE_GATEWAY_TOKEN'] = old_gateway_token
    ensure
      $VERBOSE = old_verbose
    end

  end
end
