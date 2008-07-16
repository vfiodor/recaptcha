module Merb
  module Ambethia
    def self.load
      require 'builder'
      Kernel.load(File.join(File.dirname(__FILE__) / 'merb_recaptcha/recaptcha.rb'))
    end
  end
end

# make sure we're running inside Merb
if defined?(Merb::Plugins)

  Merb::BootLoader.before_app_loads do
    # require code that must be loaded before the application

    Merb::Ambethia.load

    Merb::Controller.send(:include, Ambethia::ReCaptcha::Helper)
    Merb::Controller.send(:include, Ambethia::ReCaptcha::Controller)
  end
end
