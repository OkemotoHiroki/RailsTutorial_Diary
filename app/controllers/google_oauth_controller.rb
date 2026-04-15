# app/controllers/google_oauth_controller.rb
class GoogleOauthController < ApplicationController
  require "oauth2"
  require "google/apis/calendar_v3"
  require "googleauth"


  def start
    client = OAuth2::Client.new(
      ENV["GOOGLE_CLIENT_ID"],
      ENV["GOOGLE_CLIENT_SECRET"],
      site: "https://accounts.google.com",
      authorize_url: "/o/oauth2/auth",
      token_url: "/o/oauth2/token"
    )

    redirect_to client.auth_code.authorize_url(
      redirect_uri: google_oauth_callback_url,
      scope: "https://www.googleapis.com/auth/calendar",
      access_type: "offline",
      prompt: "consent"
    ), allow_other_host: true
  end

  def callback
    token = GoogleOauthService.exchange(params[:code], google_oauth_callback_url)

    session[:access_token] = token.token
    session[:refresh_token] = token.refresh_token

    redirect_to journals_path, notice: "Googleカレンダーと連携しました！"
  end
end
