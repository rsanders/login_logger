# LoginLogger
module Brainnovate
  module LoginLogger
    
    def log_login(options = {})
      ip = respond_to?(:session_public_ip) ? session_public_ip : request.remote_ip
      async = options.delete(:async)
      user = options.delete(:user) || (options[:failed] ? nil : current_user)
      options[:login_method] = options.delete(:method) || options.delete(:login_method)

      options = {
              :user_permtoken => cookies[:_zx_perm_uid],
              :user_agent => request.user_agent,
              :session_id => session[:session_id],
              :domain => request.host
      }.merge(options)

      options[:login_method] = options[:login_method].to_s if options[:login_method]

      unless user.blank?
        log = LoginLog.new({:user_id => user.id,
                        :login => user.login,
                        :ip_address => ip,
                        :failed => false
                        }.merge(options))
      else
        log = LoginLog.new({:login => params[:login],
                            :failed => true,
                            :ip_address => ip}.merge(options))
      end

      if async && false
        run_later do
          log.save
        end
      else
        log.save
      end
    end
  end

  module Is #:nodoc:
    module Loggable #:nodoc:

      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def is_loggable
          
          has_many :login_logs, :order => 'created_at ASC'
          
          include Brainnovate::Is::Loggable::InstanceMethods
          extend Brainnovate::Is::Loggable::SingletonMethods
        end
      end

      module SingletonMethods
        # Add class methods here
      end

      module InstanceMethods
        # Add instance methods here
      end
    end
  end
end
