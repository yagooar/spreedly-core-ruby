require 'test/unit'

require 'rubygems'
require 'bundler'

Bundler.setup(:default, :development)

Bundler.require(:default, :development)

$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'
require 'spreedly_core'
require 'spreedly_core/test_extensions'


config = YAML.load(File.read(File.dirname(__FILE__) + '/config/spreedly_core.yml'))
SpreedlyCore.configure(config['login'], config['secret'], config['gateway_token'])

