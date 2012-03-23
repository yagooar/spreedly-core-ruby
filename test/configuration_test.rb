require 'test_helper'

module SpreedlyCore
  class ConfigureTest < Test::Unit::TestCase

    def test_configure
      old_verbose, $VERBOSE = $VERBOSE, nil

      old_api_login = ENV['SPREEDLYCORE_API_LOGIN']
      old_api_secret = ENV['SPREEDLYCORE_API_SECRET']
      old_gateway_token = ENV['SPREEDLYCORE_GATEWAY_TOKEN']
      ENV['SPREEDLYCORE_API_LOGIN'] = nil
      ENV['SPREEDLYCORE_API_SECRET'] = nil
      ENV['SPREEDLYCORE_GATEWAY_TOKEN'] = nil

      assert_nothing_raised ArgumentError do
        SpreedlyCore.configure :api_login => "test",
                               :api_secret => "secret",
                               :gateway_token => "token"
      end
  
      assert_raises ArgumentError do
        SpreedlyCore.configure
      end

      ENV['SPREEDLYCORE_API_LOGIN'] = old_api_login
      ENV['SPREEDLYCORE_API_SECRET'] = old_api_secret
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
