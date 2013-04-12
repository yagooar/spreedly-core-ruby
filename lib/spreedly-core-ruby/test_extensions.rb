require 'cgi'
require 'uri'

module SpreedlyCore
  module TestHelper
    extend self

    def cc_data(cc_type, options={})

      card_numbers = {:master => [5555555555554444, 5105105105105100],
        :visa => [4111111111111111, 4012888888881881],
        :american_express => [378282246310005, 371449635398431],
        :discover => [6011111111111117, 6011000990139424]
      }

      card_number = options[:card_number] == :failed ? :last : :first
      number = card_numbers[cc_type].send(card_number)

      { :credit_card => {
          :first_name => "John",
          :last_name => "Foo",
          :card_type => cc_type,
          :number => number,
          :verification_value => 123,
          :month => 4,
          :year => Time.now.year + 1 }.merge(options[:credit_card] || {})
      }
    end

    # Return the base uri as a mocking framework would expect
    def mocked_base_uri_string
      uri = URI.parse(Base.base_uri)
      auth_params = Base.default_options[:basic_auth]
      uri.user = auth_params[:username]
      uri.password = auth_params[:password]
      uri.to_s
    end
  end

  class PaymentMethod
    # Call spreedly to create a test token.
    # pass_through_data will be added as the "data" field.
    #
    def self.create_test_token(cc_overrides = {})
      card = {
        :first_name => "John",
        :last_name => "Foo",
        :card_type => :visa,
        :number => '4111111111111111',
        :verification_value => 123,
        :month => 4,
        :year => Time.now.year + 1
      }
      if cc_overrides.is_a?(Hash)
        overrides = cc_overrides[:credit_card] || cc_overrides["credit_card"] || cc_overrides
        card.merge!(overrides)
      end

      pm = PaymentMethod.create(card)
      pm.payment_method["token"]
    end
  end
end

