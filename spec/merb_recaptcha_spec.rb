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
    Ambethia::ReCaptcha.public_key  = '0000000000000000000000000000000000000000'
    Ambethia::ReCaptcha.private_key = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
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
    Ambethia::ReCaptcha.public_key = nil
    lambda {
      recaptcha_tags
    }.should raise_error(Ambethia::ReCaptcha::ReCaptchaError)
  end
end

describe "verify_recaptcha" do
  include Ambethia::ReCaptcha::Controller

  before(:each) do
    request = mock('request')
    request.stub!(:remote_ip)
    stub!(:request).and_return(request)
    stub!(:params).and_return({})
    stub!(:session).and_return({})
  end

  it "should raise exception without private key" do
    Ambethia::ReCaptcha.private_key = nil
    lambda {
      verify_recaptcha
    }.should raise_error(Ambethia::ReCaptcha::ReCaptchaError)
  end

  it "should allow to change failure message" do
    Ambethia::ReCaptcha.private_key = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'

    recaptcha = mock('recaptcha')
    recaptcha.stub!(:body).and_return("false\nerror")
    Net::HTTP.stub!(:post_form).and_return(recaptcha)

    request = mock('request')
    request.stub!(:remote_ip)

    stub!(:request).and_return(request)
    stub!(:params).and_return({})
    stub!(:session).and_return({})

    model = mock('model')
    error = mock('error')
    model.stub!(:valid?)
    model.stub!(:errors).and_return(error)

    error.should_receive(:add_to_base).with("Custom failure message")

    verify_recaptcha(model, :failure_message => "Custom failure message")
  end
end
