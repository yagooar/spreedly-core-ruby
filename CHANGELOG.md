0.1.2 / February 29, 2012
----------

* Fix bug where a response with no body could raise a NoMethodError on NilClass


0.1.1 / February 29, 2012
----------

* Update Rakefile to include bundler tasks for building and releasing the gem


0.1.0 / February 29, 2012
----------

* Allow configuring via a set of key/values or with the traditional 3 arguments.
  For example:
  SpreedlyCore.configure :login => 'login', :secret => 'secret', :token => 'token'
   or 
  SpreeclyCore.configure 'login', 'secret', 'token'

* Handle exceptional cases better. There are 2 types of exceptions which can be
  raised by the library:
  1. SpreedlyCore::TimeOutError 
     A TimeOutError is raised if communication with SpreedlyCore takes longer
     than 10 seconds     
  2. SpreedlyCore::InvalidResponse
     An InvalidResponse is raised when the response code is unexpected (I.E. we
     expect a HTTP response code of 200 bunt instead got a 500) or if the
     response does not contain an expected attribute. For example the response
     from retaining a payment method should contain an XML attribute of
     "transaction". If this is not found (for example a HTTP response 404 or 500
     is returned), then an InvalidResponse is raised

  Both TimeOutError and InvalidResponse subclass SpreedlyCore::Error.
