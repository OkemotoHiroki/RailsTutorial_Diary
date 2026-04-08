class SessionsController < ApplicationController
  def new
  end

  def create
    auth = request.env["omniauth.auth"]
    # セッションに必要な情報を保存
    session[:google_token] = auth["credentials"]["token"]
    session[:google_refresh_token] = auth["credentials"]["refresh_token"]
    session[:google_uid] = auth["uid"]
    session[:google_email] = auth["info"]["email"]

    redirect_to journals_path, notice: "Googleでログインしました"
  end

  # ログアウト
  def destroy
    session.clear
    redirect_to journals_path, notice: "ログアウトしました"
  end
end
