require 'test_common'


# In order to run tests
#  1. cp test/config/spreedly_core.yml.example to test/config/spreedly_core.yml
#  2. Add your spreedly core credentials to test/config/spreedly_core.yml
module SpreedlyCore
  class SpreedlyCoreTest < Test::Unit::TestCase
    include TestCommon

    def test_mocked_500_error
      with_disabled_network do
        stub_request(:put, "#{mocked_base_uri_string}/payment_methods/FAKE.xml").
          to_return(:body => '', :status => 500)
        assert_raises InvalidResponse do
          Base.verify_put('/payment_methods/FAKE.xml', :has_key => "test") {}
        end
      end
    end

    def test_can_get_payment_token
      payment_method = given_a_payment_method(:master,
                                              :credit_card => {:year => 2015})
      assert_equal "John", payment_method.first_name
      assert_equal "Foo", payment_method.last_name
      assert_equal "XXX", payment_method.verification_value
      assert payment_method.errors.empty?
      assert_equal 4, payment_method.month
      assert_equal 2015, payment_method.year
    end

    def test_can_find_payment_method
      payment_method = given_a_payment_method
      assert PaymentMethod.find(payment_method.token)
    end

    def test_not_found_payment_method
      assert_raises InvalidResponse do
        PaymentMethod.find("NOT-FOUND")
      end
    end

    def test_can_retain_payment_method
      given_a_retained_transaction
    end

    # Here we change the token to get an invalid response from spreedly core
    def test_bad_response_on_retain
      payment_method = given_a_payment_method
      payment_method.instance_variable_set("@token", "NOT-FOUND")
      assert_raises InvalidResponse do
        payment_method.retain
      end
    end

    def test_can_not_retain_after_redact
      retained_transaction = given_a_retained_transaction
      payment_method = retained_transaction.payment_method
      redact_transaction = payment_method.redact
      assert redact_transaction.succeeded?
      retained_transaction2 = payment_method.retain
      assert_false retained_transaction2.succeeded?
    end

    def test_can_redact_payment_method
      given_a_redacted_transaction
    end

    # Here we change the token to get an invalid response from spreedly core
    def test_bad_response_on_redact
      payment_method = given_a_payment_method
      payment_method.instance_variable_set("@token", "NOT-FOUND")
      assert_raises InvalidResponse do
        payment_method.redact
      end
    end

    def test_can_make_purchase
      given_a_purchase
    end

    # Here we change the token to get an invalid response from spreedly core
    def test_bad_response_on_purchase
      payment_method = given_a_payment_method
      payment_method.instance_variable_set("@token", "NOT-FOUND")
      assert_raises InvalidResponse do
        payment_method.purchase(20)
      end
    end

    def test_can_authorize
      given_an_authorized_transaction
    end

    # Here we change the token to get an invalid response from spreedly core
    def test_bad_response_on_authorize
      payment_method = given_a_payment_method
      payment_method.instance_variable_set("@token", "NOT-FOUND")
      assert_raises InvalidResponse do
        payment_method.authorize(20)
      end
    end

    def test_payment_failed
      payment_method = given_a_payment_method(:master, :card_number => :failed)

      assert transaction = payment_method.purchase(100)
      assert !transaction.succeeded?
      assert_equal("Unable to process the transaction.",
                   transaction.message)

      assert_equal("Unable to process the transaction.", transaction.response.message)
    end

    def test_can_capture_after_authorize
      given_a_capture
    end

    def test_can_capture_partial_after_authorize
      given_a_capture 50
    end

    # Here we change the token to get an invalid response from spreedly core
    def test_bad_response_on_capture_after_authorize
      transaction = given_an_authorized_transaction
      transaction.instance_variable_set("@token", "NOT-FOUND")
      assert_raises InvalidResponse do
        transaction.capture
      end
    end

    def test_can_void_after_purchase
      given_a_purchase_void
    end

    # Here we change the token to get an invalid response from spreedly core
    def test_bad_response_on_void
      purchase = given_a_purchase
      purchase.instance_variable_set("@token", "NOT-FOUND")
      assert_raises InvalidResponse do
        purchase.void
      end
    end

    def test_can_void_after_capture
      given_a_capture_void
    end

    def test_can_credit_after_purchase
      given_a_purchase_credit
    end

    # Here we change the token to get an invalid response from spreedly core
    def test_bad_response_on_credit
      purchase = given_a_purchase
      purchase.instance_variable_set("@token", "NOT-FOUND")
      assert_raises InvalidResponse do
        purchase.credit
      end
    end

    def test_can_credit_partial_after_purchase
      given_a_purchase_credit(100, 50)
    end

    def test_can_credit_after_capture
      given_a_capture_credit
    end

    def test_can_credit_partial_after_capture
      given_a_capture_credit(50, 25)
    end


    def test_can_enforce_additional_payment_method_validations
      PaymentMethod.additional_required_cc_fields :state

      token = PaymentMethod.create_test_token(cc_data(:master))
      assert payment_method = PaymentMethod.find(token)
      assert !payment_method.valid?
      assert_equal 1, payment_method.errors.size

      assert_equal "State can't be blank", payment_method.errors.first

      token =  PaymentMethod.
        create_test_token(cc_data(:master, :credit_card => {:state => "IL"}))

      assert payment_method = PaymentMethod.find(token)

      assert payment_method.valid?
    end

    def test_can_list_supported_gateways
      assert Gateway.supported_gateways.any?
    end
  end
end
