require 'set'

require 'httparty'
require 'active_support/core_ext/hash/conversions'

require 'spreedly-core-ruby/base'
require 'spreedly-core-ruby/payment_method'
require 'spreedly-core-ruby/gateway'
require 'spreedly-core-ruby/test_extensions'
require 'spreedly-core-ruby/test_gateway'
require 'spreedly-core-ruby/transactions'
require 'active_support/core_ext/hash/conversions'

module SpreedlyCore
  # Hash of user friendly credit card name to Spreedly API name
  CARD_TYPES = {
    "Visa" => "visa",
    "MasterCard" => "master",
    "American Express" => "american_express",
    "Discover" => "discover"
  }

  class Error < RuntimeError; end

  # Custom exception which occurs when a request to Spreedly times out
  # See SpreedlyCore::Base.default_timeout
  class TimeOutError < Error; end
  class InvalidResponse < Error
    def initialize(response, message)
      super("#{message}\nResponse:\n#{response.inspect}")
    end
  end

  class UnprocessableRequest < Error
    attr_accessor :errors

    def initialize(errors)
      errors = [errors] unless errors.is_a?(Array)
      @errors = errors

      super(errors.join("\n"))
    end
  end

  # Configure Spreedly with a particular account.
  # Strongly prefers environment variables for credentials
  # and will issue a stern warning should they not be present.
  # Reluctantly accepts :environment_key and :access_secret as options
  def self.configure(options = {})
    environment_key = (ENV["SPREEDLYCORE_ENVIRONMENT_KEY"] || ENV['SPREEDLYCORE_API_LOGIN'])
    secret = (ENV["SPREEDLYCORE_ACCESS_SECRET"] || ENV['SPREEDLYCORE_API_SECRET'])
    gateway_token = ENV['SPREEDLYCORE_GATEWAY_TOKEN']

    if(options[:environment_key] || options[:api_login])
      Kernel.warn("ENV and arg both present for environment_key. Defaulting to arg value") if environment_key
      environment_key = (options[:environment_key] || options[:api_login])
    end

    if(options[:access_secret] || options[:api_secret])
      Kernel.warn("ENV and arg both present for access_secret. Defaulting to arg value") if secret
      secret = (options[:access_secret] || options[:api_secret])
    end

    if options[:gateway_token]
      Kernel.warn("ENV and arg both present for gateway_token. Defaulting to arg value") if gateway_token
      gateway_token = options[:gateway_token]
    end
    options[:gateway_token] ||= gateway_token

    if(options[:environment_key] || options[:access_secret])
      Kernel.warn("It is STRONGLY preferred that you house your Spreedly credentials only in environment variables.")
      Kernel.warn("This gem prefers only environment variables named SPREEDLYCORE_ENVIRONMENT_KEY, SPREEDLYCORE_ACCESS_SECRET, and optionally SPREEDLYCORE_GATEWAY_TOKEN.")
    end

    if environment_key.nil? || secret.nil?
      raise ArgumentError.new("You must provide a environment_key and a secret. Gem will look for ENV['SPREEDLYCORE_ENVIRONMENT_KEY'] and ENV['SPREEDLYCORE_ACCESS_SECRET'], but you may also pass in a hash with :environment_key and :access_secret keys.")
    end

    options[:endpoint] ||= "https://core.spreedly.com/#{SpreedlyCore::API_VERSION}"

    Base.configure(environment_key, secret, options)
  end

  def self.gateway_token=(gateway_token)
    Base.gateway_token = gateway_token
  end

  def self.gateway_token
    Base.gateway_token
  end

  # returns the configured Spreedly environment key
  def self.environment_key; Base.environment_key; end

  # A container for a response from a payment gateway
  class Response < Base
    attr_reader(
      :success,
      :message,
      :avs_code,
      :avs_message,
      :cvv_code,
      :cvv_message,
      :error_code,
      :error_detail,
      :created_at,
      :updated_at
    )
  end
end
