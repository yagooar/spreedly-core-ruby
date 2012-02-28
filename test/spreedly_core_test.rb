require "#{File.dirname(__FILE__)}/test_helper"


# In order to run tests
#  1. cp test/config/spreedly_core.yml.example to test/config/spreedly_core.yml
#  2. Add your spreedly core credentials to test/config/spreedly_core.yml 
class SpreedlyCoreTest < Test::Unit::TestCase
  include SpreedlyCore::TestHelper

  def setup
    SpreedlyCore::PaymentMethod.reset_additional_required_cc_fields
  end

  def given_a_payment_method(cc_card=:master, card_options={})
    token = SpreedlyCore::PaymentMethod.
      create_test_token(cc_data(cc_card, card_options), "customer-42")
    assert payment_method = SpreedlyCore::PaymentMethod.find(token)
    assert_equal "customer-42", payment_method.data
    assert_equal token, payment_method.token
    payment_method
  end

  def given_a_purchase(purchase_amount=100, ip_address='127.0.0.1')
    payment_method = given_a_payment_method
    assert transaction = payment_method.purchase(purchase_amount, nil, nil, ip_address=nil)
    assert_equal purchase_amount, transaction.amount
    assert_equal "USD", transaction.currency_code
    assert_equal "Purchase", transaction.transaction_type
    assert_equal ip_address, transaction.ip
    assert transaction.succeeded?
    transaction
  end

  def given_a_retained_transaction
    payment_method = given_a_payment_method
    assert transaction = payment_method.retain
    assert transaction.succeeded?
    assert_equal "RetainPaymentMethod", transaction.transaction_type
    transaction
  end

  def given_a_redacted_transaction
    retained_transaction = given_a_retained_transaction
    assert payment_method = retained_transaction.payment_method
    transaction = payment_method.redact
    assert transaction.succeeded?
    assert_equal "RedactPaymentMethod", transaction.transaction_type
    assert !transaction.token.blank?
    transaction
  end

  def given_an_authorized_transaction(amount=100, ip_address='127.0.0.1')
    payment_method = given_a_payment_method
    assert transaction = payment_method.authorize(100, nil, nil, ip_address)
    assert_equal 100, transaction.amount
    assert_equal "USD", transaction.currency_code
    assert_equal ip_address, transaction.ip
    assert_equal SpreedlyCore::AuthorizeTransaction, transaction.class
    transaction
  end
  
  def given_a_capture(amount=100, ip_address='127.0.0.1')
    transaction = given_an_authorized_transaction(amount, ip_address)
    capture = transaction.capture(amount, ip_address)
    assert capture.succeeded?
    assert_equal amount, capture.amount
    assert_equal "Capture", capture.transaction_type
    assert_equal ip_address, capture.ip
    assert_equal SpreedlyCore::CaptureTransaction, capture.class
    capture
  end

  def given_a_purchase_void(ip_address='127.0.0.1')
    purchase = given_a_purchase
    assert void = purchase.void(ip_address)
    assert_equal purchase.token, void.reference_token
    assert_equal ip_address, void.ip
    assert void.succeeded?
    void
  end

  def given_a_capture_void(ip_address='127.0.0.1')
    capture = given_a_capture
    assert void = capture.void(ip_address)
    assert_equal capture.token, void.reference_token
    assert_equal ip_address, void.ip
    assert void.succeeded?
    void
  end

  def given_a_purchase_credit(purchase_amount=100, credit_amount=100, ip_address='127.0.0.1')
    purchase = given_a_purchase(purchase_amount, ip_address)
    given_a_credit(purchase, credit_amount, ip_address)
  end

  def given_a_capture_credit(capture_amount=100, credit_amount=100, ip_address='127.0.0.1')
    capture = given_a_capture(capture_amount, ip_address)
    given_a_credit(capture, credit_amount, ip_address)
  end

  def given_a_credit(trans, credit_amount=100, ip_address='127.0.0.1')
    assert credit = trans.credit(credit_amount, ip_address)
    assert_equal trans.token, credit.reference_token
    assert_equal credit_amount, credit.amount
    assert_equal ip_address, credit.ip
    assert credit.succeeded?
    assert SpreedlyCore::CreditTransaction, credit.class
    credit
  end

  def test_configure
    SpreedlyCore.configure(:login => "test", :secret => "secret",
                           :gateway_token => "token")

    SpreedlyCore.configure('login' => 'test', 'secret' => 'secret',
                           'gateway_token' => 'token')

    SpreedlyCore.configure('test', 'secret', 'token')

    assert_raises ArgumentError do
      SpreedlyCore.configure
    end

    assert_raises ArgumentError do
      SpreedlyCore.configure({})
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

  def test_can_retain_payment_method
    given_a_retained_transaction
  end

  def test_can_redact_payment_method
    given_a_redacted_transaction
  end

  def test_can_make_purchase
    given_a_purchase
  end

  def test_can_authorize
    given_an_authorized_transaction
  end

  def test_payment_failed
    payment_method = given_a_payment_method(:master, :card_number => :failed)

    assert transaction = payment_method.purchase(100)
    assert !transaction.succeeded?
    assert_equal("Unable to obtain a successful response from the gateway.",
                 transaction.message)

    assert_equal("Unable to process the transaction.", transaction.response.message)
  end

  def test_can_capture_after_authorize
    given_a_capture
  end

  def test_can_capture_partial_after_authorize
    given_a_capture 50
  end

  def test_can_void_after_purchase
    given_a_purchase_void
  end

  def test_can_void_after_capture
    given_a_capture_void
  end

  def test_can_credit_after_purchase
    given_a_purchase_credit
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

  def test_find_returns_retain_transaction_type
    retain = given_a_retained_transaction
    assert_find_transaction(retain, SpreedlyCore::RetainTransaction)
  end

  def test_find_returns_redact_transaction_type
    redact = given_a_redacted_transaction
    assert_find_transaction(redact, SpreedlyCore::RedactTransaction)
  end

  def test_find_returns_authorize_transaction_type
    authorize = given_an_authorized_transaction
    assert_find_transaction(authorize, SpreedlyCore::AuthorizeTransaction)
  end

  def test_find_returns_purchase_transaction_type
    purchase = given_a_purchase
    assert_find_transaction(purchase, SpreedlyCore::PurchaseTransaction)
  end

  def test_find_returns_capture_transaction_type
    capture = given_a_capture
    assert_find_transaction(capture, SpreedlyCore::CaptureTransaction)
  end

  def test_find_returns_voided_transaction_type
    void = given_a_capture_void
    assert_find_transaction(void, SpreedlyCore::VoidedTransaction)
  end

  def test_find_returns_credit_transaction_type
    credit = given_a_capture_credit
    assert_find_transaction(credit, SpreedlyCore::CreditTransaction)
  end

  
  def test_can_enforce_additional_payment_method_validations
    SpreedlyCore::PaymentMethod.additional_required_cc_fields :state

    token = SpreedlyCore::PaymentMethod.create_test_token(cc_data(:master))
    assert payment_method = SpreedlyCore::PaymentMethod.find(token)
    assert !payment_method.valid?
    assert_equal 1, payment_method.errors.size

    assert_equal "State can't be blank", payment_method.errors.first

    token =  SpreedlyCore::PaymentMethod.
      create_test_token(cc_data(:master, :credit_card => {:state => "IL"}))

    assert payment_method = SpreedlyCore::PaymentMethod.find(token)

    assert payment_method.valid?
  end

  def test_can_list_supported_gateways
    assert SpreedlyCore::Gateway.supported_gateways.any?
  end

  protected
  def assert_find_transaction(trans, expected_class)
    assert actual = SpreedlyCore::Transaction.find(trans.token)
    assert_equal expected_class, actual.class
  end
end
