class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :load_user

  private def load_user
    user_uuid = cookies[:user_uuid]
    if user_uuid
      @user = User.where(uuid: user_uuid).first
    else
      @user = User.create()
      cookies[:user_uuid] = @user.uuid
    end
  end

end
