require 'test/unit'

require 'rubygems'
require 'bundler'

Bundler.setup(:default, :development)

Bundler.require(:default, :development)

$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'
require 'spreedly-core-ruby'
require 'spreedly-core-ruby/test_extensions'
require 'test_factory'

require 'webmock/test_unit'
# Allow real connections, see https://github.com/bblimke/webmock for more info
WebMock.allow_net_connect!

require 'webmock'

class Test::Unit::TestCase
  def assert_false(test, failure_message=nil)
    failure_message = "" if failure_message.nil?
    assert(!test, failure_message)
  end

  def with_disabled_network(&block)
    WebMock.disable_net_connect!
    block.call
  ensure
    WebMock.allow_net_connect!
  end

end
