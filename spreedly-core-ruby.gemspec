$LOAD_PATH.unshift 'lib'
require "spreedly-core-ruby/version"

Gem::Specification.new do |s|
  s.name              = "spreedly-core-ruby"
  s.version           = SpreedlyCore::VERSION
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           = "Ruby API for Spreedly Core"
  s.homepage          = "http://github.com/spreedly/spreedly-core-ruby"
  s.email             = "support@spreedly.com"
  s.authors           = [ "Spreedly", "403 Labs" ]

  s.files             = %w( README.md Rakefile LICENSE )
  s.files            += Dir.glob("lib/**/*")
  s.files            += Dir.glob("bin/**/*")
  s.files            += Dir.glob("man/**/*")
  s.files            += Dir.glob("test/**/*")

  s.add_runtime_dependency     'httparty', '0.7.7'
  s.add_runtime_dependency     'activesupport', '~> 3.0.0'
  s.add_runtime_dependency     'builder'

  s.add_development_dependency "ruby-debug#{RUBY_VERSION =~ /1.9.\d/ ? "19" : ""}"
  s.add_development_dependency 'rake', '0.8.7'
  s.add_development_dependency 'webmock', '~> 1.6.2'
end
