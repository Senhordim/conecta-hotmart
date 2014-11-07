class NotificationsController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: :get_notification
  skip_before_filter :authenticate_user!, only: :get_notification

  def get_notification
    Rails.logger.info "Token: #{params[:token]}\n"
    Rails.logger.info "Response.header #{response.header}\n"
    Rails.logger.info "Response.body: #{response.body}\n"
    Rails.logger.info "Request.body: #{request.body}\n"
    Rails.logger.info "Params: #{params}\n"
    
    if is_from_help_scout?(params[:data], params[:token])
      user_id = User.find_by_helpscout_token(params[:token]).first.id
      HotmartNotification.find_by_user_id(user_id)
      render nothing: true, status: 200
    else
      render nothing: true, status: 401
    end
  end

  private

  # require 'openssl'
  # require 'base64'

  # WEBHOOK_SECRET_KEY = "your secret key"

  def is_from_help_scout?(data, signature)
    return false if data.nil? || signature.nil?
    hmac = OpenSSL::HMAC.digest('sha1', WEBHOOK_SECRET_KEY, data)
    Base64.encode64(hmac).strip == signature.strip
  end

  # def helpscout_signature(data, token)
  #   hmac = OpenSSL::HMAC.digest('sha1', token, data)
  #   Base64.encode64(hmac.strip)
  # end
end