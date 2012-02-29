require 'test_helper'

module SpreedlyCore
  class ConfigureTest < Test::Unit::TestCase

    def test_configure
      SpreedlyCore.configure :login => "test",
                             :secret => "secret",
                             :gateway_token => "token"
  
      SpreedlyCore.configure 'login' => 'test',
                             'secret' => 'secret',
                             'gateway_token' => 'token'
  
      SpreedlyCore.configure 'test', 'secret', 'token'
  
      assert_raises ArgumentError do
        SpreedlyCore.configure
      end

      assert_raises ArgumentError do
        SpreedlyCore.configure {}
      end
    end
    
  end
end
