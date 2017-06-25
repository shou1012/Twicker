class SessionsController < ApplicationController
  def create
    if (request.path_info == "/auth/twitter/callback")
      auth = request.env["omniauth.auth"]
      session[:oauth_token] = auth.credentials.token
      session[:oauth_token_secret] = auth.credentials.secret
      session[:username] = auth.extra.access_token.params[:screen_name]
      redirect_to "/tweet", :notice => "サインイン！"
    else
      redirect_to root_url
    end
  end

  def destroy
    session[:oauth_token] = nil
    session[:oauth_token_secret] = nil
    redirect_to root_url, :notice => "サインアウト！"
    if (request.path_info == "/signout_twitter")
      session[:username] = nil
    end
  end
end
