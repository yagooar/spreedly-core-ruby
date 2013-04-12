Spreedly
======
spreedly-core-ruby is a Ruby library for accessing the [Spreedly API](https://spreedly.com/). Spreedly is a Software-as-a-Service billing solution that serves two major functions for companies and developers.

* First, it removes your [PCI Compliance](https://www.pcisecuritystandards.org/) requirement by pushing the card data handling and storage outside of your application. This is possible by having your customers POST their credit card info to the Spreedly service while embedding a transparent redirect URL back to your application (see "Submit payment form" on [the quick start guide](https://spreedly.com/manual/quickstart)).
* Second, it removes any possibility of your gateway locking you in by owning your customer billing data (yes, this happens). By allowing you to charge any card against whatever gateways you as a company have signed up for, you retain all of your customer data and can switch between gateways as you please. Also, expanding internationally won't require an additional technical integration with yet another gateway.

Credit where credit is due: our friends over at [403 Labs](http://www.403labs.com/) carried most of the weight in cutting the initial version of this gem, and we can't thank them enough for their work.

Quickstart
----------
Head over to the [Spreedly Website](https://www.spreedly.com) to sign up for an account. It's free to get started and play with test gateways/transactions using our specified test card data.

RubyGems:

    export SPREEDLYCORE_ENVIRONMENT_KEY=your_environment_key_here
    export SPREEDLYCORE_ACCESS_SECRET=your_secret_here
    gem install spreedly-core-ruby
    irb
    require 'rubygems'
    require 'spreedly-core-ruby'
    SpreedlyCore.configure

The first thing we'll need to do is set up a test gateway that we can run transactions against. Then, we'll tell the gem to use the newly created gateway for all future calls.

    tg = SpreedlyCore::TestGateway.get_or_create
    tg.use!

Now that you have a test gateway set up, we'll need to set up your payment form to post the credit card data directly to Spreedly. Spreedly will receive your customer's credit card data, and immediately transfer them back to the location you define inside the web payments form. The user won't know that they're being taken off site to record to the card data, and you as the developer will be left with a token identifier. The token identifier is used to make your charges against, and to access the customer's non-sensitive billing information.

    <form action="https://core.spreedly.com/v1/payment_methods" method="POST">
	    <fieldset>
	        <input name="redirect_url" type="hidden" value="http://example.com/transparent_redirect_complete" />
	        <input name="environment_key" type="hidden" value="Ll6fAtoVSTyVMlJEmtpoJV8Shw5" />
	        <label for="credit_card_first_name">First name</label>
	        <input id="credit_card_first_name" name="credit_card[first_name]" type="text" />

	        <label for="credit_card_last_name">Last name</label>
	        <input id="credit_card_last_name" name="credit_card[last_name]" type="text" />

	        <label for="credit_card_number">Card Number</label>
	        <input id="credit_card_number" name="credit_card[number]" type="text" />

	        <label for="credit_card_verification_value">Security Code</label>
	        <input id="credit_card_verification_value" name="credit_card[verification_value]" type="text" />

	        <label for="credit_card_month">Expires on</label>
	        <input id="credit_card_month" name="credit_card[month]" type="text" />
	        <input id="credit_card_year" name="credit_card[year]" type="text" />

	        <button type='submit'>Submit Payment</button>
	    </fieldset>
	</form>

Take special note of the **environment_key** and **redirect_url** params hidden in the form, as Spreedly will use both of these fields to authenticate the developer's account and to send the customer back to the right location in your app.

A note about test card data
----------------
If you've just signed up and have not entered your billing information (or selected a Heroku paid plan), you will only be permitted to deal with [test credit card data](https://core.spreedly.com/manual/test-data).

Once you've created your web form and submitted one of the test cards above, you should be returned to your app with a token identifier by which to identify your newly created payment method. Let's go ahead and look up that payment method by the token returned to your app, and we'll charge $5.50 to it.

    payment_token = 'abc123' # extracted from the URL params
    payment_method = SpreedlyCore::PaymentMethod.find(payment_token)
    if payment_method.valid?
      purchase_transaction = payment_method.purchase(550)
      purchase_transaction.succeeded? # true
    else
      flash[:notice] = "Woops!\n" + payment_method.errors.join("\n")
    end

Saving Payment Methods
----------
Spreedly allows you to retain payment methods provided by your customer for future use. In general, removing the friction from your checkout process is one of the best things you can do for your application, and using Spreedly will allow you to avoid making your customer input their payment details for every purchase.

    payment_token = 'abc123' # extracted from the URL params
    payment_method = SpreedlyCore::PaymentMethod.find(payment_token)
    if payment_method.valid?
      puts "Retaining payment token #{payment_token}"
      retain_transaction = payment_method.retain
      retain_transaction.succeeded? # true
    end

Payment methods that you no longer want to retain can be redacted from Spreedly. A redacted payment method has its sensitive information removed.

    payment_token = 'abc123' # extracted from the URL params
    payment_method = SpreedlyCore::PaymentMethod.find(payment_token)
    redact_transaction = payment_method.redact
    redact_transaction.succeeded? # true

Usage Overview
----------
Make a purchase against a payment method

    purchase_transaction = payment_method.purchase(1245)


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

Credit (refund) a previous purchase:

    purchase_transaction = payment_method.purchase(100) # make a purchase
    purchase_transaction.credit
    purchase_transaction.succeeded? # true

Credit part of a previous purchase:

    purchase_transaction = payment_method.purchase(100) # make a purchase
    purchase_transaction.credit(50) # provide a partial credit
    purchase_transaction.succeeded? # true


Handling Exceptions
--------
There are 3 types of exceptions which can be raised by the library:

1. SpreedlyCore::TimeOutError is raised if communication with Spreedly takes longer than 10 seconds
2. SpreedlyCore::InvalidResponse is raised when the response code is unexpected (I.E. we expect a HTTP response code of 200 bunt instead got a 500) or if the response does not contain an expected attribute. For example, the response from retaining a payment method should contain an XML attribute of "transaction". If this is not found (for example a HTTP response 404 or 500 is returned), then an InvalidResponse is raised.
3. SpreedlyCore::UnprocessableRequest is raised when the response code is 422. This denotes a validation error where one or more of the data fields submitted were not valid, or the whole record was unable to be saved/updated. Inspection of the exception message will give an explanation of the issue.


Each of TimeOutError, InvalidResponse, and UnprocessableRequest subclass SpreedlyCore::Error.

For example, let's look up a payment method that does not exist:

    begin
      payment_method = SpreedlyCore::PaymentMethod.find("NOT-FOUND")
    rescue SpreedlyCore::InvalidResponse => e
      puts e.inspect
    end


Configuring Spreedly for Use in Production (Rails example)
----------
When you're ready for primetime, you'll need to complete a couple more steps to start processing real transactions.

1. First, you'll need to get your business (or personal) payment details on file with Spreedly so that we can collect transaction and card retention fees. For those of you using Heroku, simply change your Spreedly addon to the paid tier.
2. Second, you'll need to acquire a gateway that you can plug into the back of Spreedly. Any of the major players will work, and you're not at risk of lock-in because Spreedly happily plays middle man. Please consult our [list of supported gateways](https://core.spreedly.com/manual/gateways) to see exactly what information you'll need to pass to Spreedly when creating your gateway profile.

For this example, I will be using an Authorize.net account that only has a login and password credential.

    SpreedlyCore.configure

    gateway = SpreedlyCore::Gateway.create(:login => 'my_authorize_login', :password => 'my_authorize_password', :gateway_type => 'authorize_net')
    gateway.use!

    puts "Authorize.net gateway token is #{gateway.token}"

For most users, you will start off using only one gateway token, and as such can configure it as an environment variable to hold your gateway token. In addition to the previous environment variables, the `SpreedlyCore.configure` method will also look for a SPREEDLYCORE_GATEWAY_TOKEN environment value.

	# create an initializer at config/initializers/spreedly_core.rb
    # values already set for ENV['SPREEDLYCORE_ENVIRONMENT_KEY'], ENV['SPREEDLYCORE_ACCESS_SECRET'], and ENV['SPREEDLYCORE_GATEWAY_TOKEN']
    SpreedlyCore.configure

If you wish to require additional credit card fields, the initializer is the best place to set this up.

    SpreedlyCore.configure
    SpreedlyCore::PaymentMethod.additional_required_cc_fields :address1, :city, :state, :zip

Using Multiple Gateways
------------
For those using multiple gateway tokens, there is a class variable that holds the active gateway token. Before running any sort of transaction against a payment method, you'll need to set the gateway token that you wish to charge against.

    SpreedlyCore.configure

    SpreedlyCore.gateway_token(paypal_gateway_token)
    SpreedlyCore::PaymentMethod.find(pm_token).purchase(550)

    SpreedlyCore.gateway_token(authorize_gateway_token)
    SpreedlyCore::PaymentMethod.find(pm_token).purchase(2885)

    SpreedlyCore.gateway_token(braintree_gateway_token)
    SpreedlyCore::PaymentMethod.find(pm_token).credit(150)

Creating Payment Types Programatically
------------
**Please note that this practice requires you to be PCI compliant!**

In special cases, you may want to create payment types programmatically and will not be using the transparent redirect functionality. This can be done using the `SpreedlyCore::PaymentMethod.create` method, and will behave as follows:

* Card validation is done in realtime, and a 422 Unprocessable will be returned if validation fails.
* Successful execution will return an AddPaymentMethodTransaction object (*not* a PaymentMethod object). Adding a payment method is wrapped in a transaction much like doing a purchase or authorize request is. The returned object will have the PaymentMethod object as a child.
* You still need to manually call `retain` on the payment method if you wish to retain the card.

The example below illustrates both a successful payment method creation, and how to handle one with errors.

	SpreedlyCore.configure

	pm_transaction = SpreedlyCore::PaymentMethod.create(:credit_card => good_card_hash)
	pm_token = pm_transaction.payment_method.token
	puts "Payment method token is #{pm_token}"

	retain_transaction = pm_transaction.payment_method.retain
	retain_transaction.succeeded? # true

	begin
      pm_transaction = SpreedlyCore::PaymentMethod.create(:credit_card => bad_card_hash)
    rescue Exception => e
      puts "Errors when submitting the card: #{e.errors.join(",")}"
    end

Contributing
------------
1. [Fork](http://help.github.com/forking/) spreedly-core-ruby
2. Create a topic branch - `git checkout -b my_branch`
3. Make your changes on your topic branch.
4. DO NOT bump the version number, or put it in a separate commit that I can ignore.
3. Push to your branch - `git push origin my_branch`
4. Create a [Pull Request](http://help.github.com/pull-requests/) from your branch

