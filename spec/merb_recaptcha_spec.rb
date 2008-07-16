require File.dirname(__FILE__) + '/spec_helper'
require File.dirname(__FILE__) + '/../lib/merb_recaptcha/recaptcha'
require 'rubygems'
require 'builder'

describe "merb_recaptcha" do
  include Ambethia::ReCaptcha
  include Ambethia::ReCaptcha::Helper
  include Ambethia::ReCaptcha::Controller
  attr_accessor :session

  before(:each) do
    RECAPTCHA_PUBLIC_KEY  = '0000000000000000000000000000000000000000'
    RECAPTCHA_PRIVATE_KEY = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
    @session = {}
  end

  it "should render recaptcha tags" do
    recaptcha_tags.should include("http://api.recaptcha.net")
  end

  it "should render recaptcha tags with ssl" do
    recaptcha_tags(:ssl => true).should include("https://api-secure.recaptcha.net")
  end

  it "should render recaptcha tags without noscript" do
     recaptcha_tags(:noscript => false).should_not include("noscript")
  end

  it "should raise exception without public key" do
    RECAPTCHA_PUBLIC_KEY = nil
    lambda {
      recaptcha_tags
    }.should raise_error(Ambethia::ReCaptcha::ReCaptchaError)
  end
end
