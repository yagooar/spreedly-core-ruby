require 'test/unit'

require 'rubygems'
require 'bundler'

Bundler.setup(:default, :development)

Bundler.require(:default, :development)

$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'
require 'spreedly_core'
require 'spreedly_core/test_extensions'
require 'test_factory'

class Test::Unit::TestCase
  def assert_false(test, failure_message=nil)
    assert(!test, failure_message)
  end
end
