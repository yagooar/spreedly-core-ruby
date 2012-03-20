require 'test_helper'

module SpreedlyCore
  class ConfigureTest < Test::Unit::TestCase

    def test_configure
      old_verbose, $VERBOSE = $VERBOSE, nil

      old_login = ENV['SPREEDLYCORE_API_LOGIN']
      old_secret = ENV['SPREEDLYCORE_API_SECRET']
      ENV['SPREEDLYCORE_API_LOGIN'] = nil
      ENV['SPREEDLYCORE_API_SECRET'] = nil

      assert_nothing_raised ArgumentError do
        SpreedlyCore.configure :api_login => "test",
                               :api_secret => "secret",
                               :gateway_token => "token"
      end
  
      assert_raises ArgumentError do
        SpreedlyCore.configure
      end

      ENV['SPREEDLYCORE_API_LOGIN'] = old_login
      ENV['SPREEDLYCORE_API_SECRET'] = old_secret

      assert_nothing_raised ArgumentError do
        SpreedlyCore.configure
      end
    ensure
      $VERBOSE = old_verbose
    end
    
  end
end
