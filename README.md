SpreedlyCore
======

SpreedlyCore is a Ruby library for accessing the [Spreedly Core API](https://spreedlycore.com/).

The beauty behind Spreedly Core is that you lower your
[PCI Compliance](https://www.pcisecuritystandards.org/) risk 
by storing credit card information on their service while still having access
to make payments and credits. This is possible by having your customers POST their
credit card info to the spreedly core service while embedding a transparent
redirect URL back to your application. See "Submit payment form" on
[the quick start guide](https://spreedlycore.com/manual/quickstart)
how the magic happens.


Quickstart
----------

RubyGems:

    gem install spreedly_core
    irb
    require 'rubygems'
    require 'spreedly_core'
    SpreedlyCore.configure("Your API Login", "Your API Secret", "Test Gateway Token")
See the [quickstart guide](https://spreedlycore.com/manual/quickstart) for
information regarding tokens.

We'll now look up the payment method stored on SpreedlyCore using token param
from the transparent redirect URL
 
    payment_token = SpreedlyCore::PaymentMethod.find(payment_token)
    transaction = payment_token.purchase(100)

Test Integration
----------
    
Since your web form handles the creation of payment methods on their service,
integration testing can be a bit of a headache. No worries though:

    require 'spreedly_core'
    require 'spreedly_core/test_extensions'
    SpreedlyCore.configure("Your API Login", "Your API Secret", "Test Gateway Token")
    master_card_data = SpreedlyCore::TestHelper.cc_data(:master) # Lookup test credit card data
    token = SpreedlyCore::PaymentMethod.create_test_token(master_card_data)

You now have access to a payment method token, which can be used just like your
application would use it. Note, you should use a test gateway since you are
actually hitting the Spreedly Core service. Let's use the test credit card
payment method to make a purchase:
    
    payment_method = SpreedlyCore::PaymentMethod.find(token)
    purchase_transaction = payment_method.purchase(100)
    purchase_transaction.succeeded? # true

Let's now use a credit card that is configured to fail upon purchase:

    master_card_data = SpreedlyCore::TestHelper.cc_data(:master, :card_type => :failed)
    token = SpreedlyCore::PaymentMethod.create_test_token(master_card_data)
    payment_method = SpreedlyCore::PaymentMethod.find(token)
    purchase_transaction = payment_method.purchase(100)
    purchase_transaction.succeeded? # false

Other test cards available include :visa, :american_express, and :discover
    
Usage
----------

Using spreedly_core in irb:

    require 'spreedly_core'
    require 'spreedly_core/test_extensions' # allow creating payment methods from the command line
    SpreedlyCore.configure("Your API Login", "Your API Secret", "Test Gateway Token")
    # or if loading from YAML for example, configure takes a hash as well
    SpreedlyCore.configure(:login => "Your API Login", :secret => "Your API Secret",
                           :token => "Test Gateway Token")       
    master_card_data = SpreedlyCore::TestHelper.cc_data(:master)
    token = SpreedlyCore::PaymentMethod.create_test_token(master_card_data)


Look up a payment method:

    payment_method = SpreedlyCore::PaymentMethod.find(token)

Retain a payment method for later use:

    retain_transaction = payment_method.retain
    retain_transaction.succeeded? # true

Redact a previously retained payment method:

    redact_transaction = payment_method.redact
    redact_transaction.succeeded?

Make a purchase against a payment method:

    purchase_transaction = payment_method.purchase(100) 
    purchase_transaction.succeeded? # true

Make an authorize request against a payment method, then capture the payment

    authorize = payment_method.authorize(100)
    authorize.succeeded? # true
    capture = authorize.capture(50) # Capture only half of the authorized amount
    capture.succeeded? # true

    authorize = payment_method.authorize(100)
    authorize.succeeded? # true
    authorized.capture # Capture the full amount
    capture.succeeded? # true
    
Void a previous purchase:

    purchase_transaction.void # void the purchase

Credit a previous purchase:

    purchase_transaction = payment_method.purchase(100) # make a purchase
    purchase_transaction.credit
    purchase_transaction.succeeded? # true 

Credit part of a previous purchase:

    purchase_transaction = payment_method.purchase(100) # make a purchase
    purchase_transaction.credit(50) # provide a partial credit
    purchase_transaction.succeeded? # true 

Handling Exceptions:

There are 2 types of exceptions which can be raised by the library:

  1.  SpreedlyCore::TimeOutError is raised if communication with SpreedlyCore
      takes longer than 10 seconds     
  2.  SpreedlyCore::InvalidResponse is raised when the response code is
      unexpected (I.E. we expect a HTTP response code of 200 bunt instead got a
      500) or if the response does not contain an expected attribute. For
      example, the response from retaining a payment method should contain an XML
      attribute of "transaction". If this is not found (for example a HTTP
      response 404 or 500 is returned), then an InvalidResponse is raised.

      
Both TimeOutError and InvalidResponse subclass SpreedlyCore::Error.

Look up a payment method that does not exist:

    begin
      payment_method = SpreedlyCore::PaymentMethod.find("NOT-FOUND")
    rescue SpreedlyCore::InvalidResponse => e
      puts e.inspect
    end  

   
Additional Field Validation
----------


The Spreedyly Core API provides validation of the credit card number, CVE, and
first and last name. In most cases this is enough, however sometimes you want to
enforce the billing information as well. This can be accomplished via:

    require 'spreedly_core'
    require 'spreedly_core/test_extensions'
    SpreedlyCore.configure("Your API Login", "Your API Secret", "Test Gateway Token")
    SpreedlyCore::PaymentMethod.additional_required_cc_fields :address1, :city, :state, :zip
    master_card_data = SpreedlyCore::TestHelper.cc_data(:master)
    token = SpreedlyCore::PaymentMethod.create_test_token(master_card_data)
    payment_method = SpreedlyCore::PaymentMethod.find(token)
    payment_method.valid? # returns false
    payment_method.errors # ["Address1 can't be blank", "City can't be blank", "State can't be blank", "Zip can't be blank"]
    master_card_data = SpreedlyCore::TestHelper.cc_data(:master, :credit_card => {:address1 => "742 Evergreen Terrace", :city => "Springfield", :state => "IL", 62701})
    payment_method = SpreedlyCore::PaymentMethod.find(token)
    payment_method.valid? # returns true
    payment_method.errors # []

   
Configuring SpreedlyCore with Rails
----------

Inside your Rails project create config/spreedly_core.yml formatted like config/database.yml. For example:

    development:
      login: <Login Key>
      secret: <Secret Key>
      gateway_token: 'JncEWj22g59t3CRB1VnPXmUUgKc' # this is the test gateway, replace with your real gateway in production
    test:
      login: <Login Key>
      secret: <Secret Key>
      gateway_token: 'JncEWj22g59t3CRB1VnPXmUUgKc' # this is the test gateway, replace with your real gateway in production
    production:
      login: <Login Key>
      secret: <Secret Key>
      gateway_token: 'JncEWj22g59t3CRB1VnPXmUUgKc' # this is the test gateway, replace with your real gateway in production

Then create config/initializers/spreedly_core.rb with the following:

    config = YAML.load(File.read(RAILS_ROOT + '/config/spreedly_core.yml'))[RAILS_ENV]
    SpreedlyCore.configure(config)

Optionally require additional credit card fields:

    SpreedlyCore::PaymentMethod.additional_required_cc_fields :address1, :city, :state, :zip  

Contributing
------------

Once you've made your commits:

1. [Fork](http://help.github.com/forking/) SpreedlyCore
2. Create a topic branch - `git checkout -b my_branch`
3. Push to your branch - `git push origin my_branch`
4. Create a [Pull Request](http://help.github.com/pull-requests/) from your branch
5. Profit! 

