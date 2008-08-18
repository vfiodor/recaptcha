# ReCAPTCHA
module Ambethia
  module ReCaptcha
    @@public_key = ENV['RECAPTCHA_PUBLIC_KEY']
    @@private_key = ENV['RECAPTCHA_PRIVATE_KEY']

    def self.recaptcha_api_server
      'http://api.recaptcha.net'
    end

    def self.recaptcha_api_secure_server
      'https://api-secure.recaptcha.net'
    end

    def self.recaptcha_verify_server
      'api-verify.recaptcha.net'
    end

    def self.public_key=(value)
      @@public_key = value
    end

    def self.public_key
      @@public_key
    end

    def self.private_key=(value)
      @@private_key = value
    end

    def self.private_key
      @@private_key
    end

    module Helper 
      # Your public API can be specified in the +options+ hash or preferably the environment
      # variable +RECAPTCHA_PUBLIC_KEY+.
      def recaptcha_tags(options = {})
        # Default options
        key   = options[:public_key] ||= Ambethia::ReCaptcha.public_key
        error = options[:error] ||= session[:recaptcha_error]
        uri   = options[:ssl] ? Ambethia::ReCaptcha.recaptcha_api_secure_server : Ambethia::ReCaptcha.recaptcha_api_server
        xhtml = Builder::XmlMarkup.new :target => out=(''), :indent => 2 # Because I can.
        if options[:display] 
          xhtml.script(:type => "text/javascript"){ xhtml.text! "var RecaptchaOptions = #{options[:display].to_json};\n"}
        end
        xhtml.script(:type => "text/javascript", :src => "#{uri}/challenge?k=#{key}&error=#{error}") {}
        unless options[:noscript] == false
          xhtml.noscript do
            xhtml.iframe(:src => "#{uri}/noscript?k=#{key}",
                         :height => options[:iframe_height] ||= 300,
                         :width  => options[:iframe_width]  ||= 500,
                         :frameborder => 0) {}; xhtml.br
            xhtml.textarea(:name => "recaptcha_challenge_field", :rows => 3, :cols => 40) {}
            xhtml.input :name => "recaptcha_response_field",
                        :type => "hidden", :value => "manual_challenge"
          end
        end
        raise ReCaptchaError, "No public key specified." unless key
        return out
      end # recaptcha_tags
    end # Helpers
    
    module Controller
      # Your private API key must be specified in the environment variable +RECAPTCHA_PRIVATE_KEY+
      def verify_recaptcha(model = nil, options = {})
        raise ReCaptchaError, "No private key specified." unless Ambethia::ReCaptcha.private_key
        begin
          recaptcha = Net::HTTP.post_form URI.parse("http://#{Ambethia::ReCaptcha.recaptcha_verify_server}/verify"), {
            :privatekey => Ambethia::ReCaptcha.private_key,
            :remoteip   => request.remote_ip,
            :challenge  => params[:recaptcha_challenge_field],
            :response   => params[:recaptcha_response_field]
          }
          answer, error = recaptcha.body.split.map {|i| i.chomp}
          unless answer == 'true'
            session[:recaptcha_error] = error
            model.valid? if model
            model.errors.add_to_base(options[:failure_message] || "Captcha response is incorrect, please try again.") if model
            return false
          else
            session[:recaptcha_error] = nil
            return true
          end
        rescue Exception => e
          raise ReCaptchaError, e
        end    
      end # verify_recaptcha
    end # ControllerHelpers

    class ReCaptchaError < StandardError; end
    
  end # ReCaptcha
end # Ambethia
