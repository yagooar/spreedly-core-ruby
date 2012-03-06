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

  # Configure SpreedlyCore with a particular account.
  # Strongly prefers environment variables for credentials
  # and will issue a stern warning should they not be present.
  # Reluctantly accepts :login and :secret as options
  def self.configure(options = {})
    login = ENV['SPREEDLYCORE_API_LOGIN']
    secret = ENV['SPREEDLYCORE_API_SECRET']

    unless login && secret
      Kernel.warn("It is STRONGLY preferred that you house your Spreedly Core credentials in environment variables.")
      Kernal.warn("This gem is expecting variables named SPREEDLYCORE_API_LOGIN and SPREEDLYCORE_API_SECRET.")
    end

    login ||= options[:login]
    secret ||= options[:secret]

    if login.nil? || secret.nil?
      raise ArgumentError.new("You must provide a login and a secret. Gem will look for ENV['SPREEDLYCORE_API_LOGIN'] and ENV['SPREEDLYCORE_API_SECRET'], but you may also pass in a hash with :login and :secret keys.")
    end
    Base.configure(login, secret)
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
