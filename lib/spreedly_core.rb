require 'set'

require 'httparty'

require 'spreedly_core/base'
require 'spreedly_core/payment_method'
require 'spreedly_core/gateway'
require 'spreedly_core/transactions'

module SpreedlyCore
  # Hash of user friendly credit card name to SpreedlyCore API name
  CARD_TYPES = {
    "Visa" => "visa",
    "MasterCard" => "master",
    "American Express" => "american_express",
    "Discover" => "discover"
  }

  class Error < RuntimeError; end
  # Custom exception which occurs when a request to SpreedlyCore times out
  # See SpreedlyCore::Base.default_timeout 
  class TimeOutError < Error; end
  class InvalidResponse < Error
    def initialize(response, message)
      super("#{message}\nResponse:\n#{response.inspect}")
    end
  end

  # Configure SpreedlyCore with a particular account and default gateway
  # If the first argume is a hash, 'login', 'secret', and 'gateway_token'
  # keys are expected. Otherwise *args is expected to be login, secret,
  # and gateway_token
  def self.configure(*args)
    login_or_hash, secret, gateway_token, *rest = args
    if login_or_hash.is_a?(Hash)

      # convert symbols to strings
      login_or_hash.each{|k,v| login_or_hash[k.to_s] = v }

      login = login_or_hash['login']
      secret = login_or_hash['secret']
      gateway_token = login_or_hash['gateway_token']
    else
      login = login_or_hash
    end
    if login.nil? || secret.nil? || gateway_token.nil?
      raise ArgumentError.new("You must provide a login, secret, and gateway_token")
    end
    Base.configure(login, secret, gateway_token)
  end

  # returns the configured SpreedlyCore login
  def self.login; Base.login; end

  # A container for a response from a payment gateway
  class Response < Base
    attr_reader(:success, :message, :avs_code, :avs_message, :cvv_code,
                :cvv_message, :error_code, :error_detail, :created_at,
                :updated_at) 
  end
end
