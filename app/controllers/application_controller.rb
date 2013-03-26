# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include SslRequirement

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  protected
  def ensure_proper_protocol
    if !ssl_allowed? && ssl_required? && !request.ssl? && !(request.get? || request.head?)
      raise 'SSL required!' # either we have a bug somewhere or someone is playing with us.
    else
      super
    end
  end
end
