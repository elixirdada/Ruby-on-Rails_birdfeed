class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def facebook
    @user = User.from_omniauth(request.env["omniauth.auth"])
    if @user.persisted?
      sign_in_and_redirect @user
    elsif User.find_by(email: request.env["omniauth.auth"].info.email)
      user = User.find_by(email: request.env["omniauth.auth"].info.email)
      user.update(provider: request.env["omniauth.auth"].provider, uid: request.env["omniauth.auth"].uid)
      sign_in_and_redirect user
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"].select { |k, v| k == "email" }
      redirect_to choose_profile_path(anchor: 'step-1')
    end
  end

  def google_oauth2
    @user = User.from_omniauth(request.env["omniauth.auth"])
    if @user.persisted?
      sign_in_and_redirect @user
    elsif User.find_by(email: request.env["omniauth.auth"].info.email)
      user = User.find_by(email: request.env["omniauth.auth"].info.email)
      user.update(provider: request.env["omniauth.auth"].provider, uid: request.env["omniauth.auth"].uid)
      sign_in_and_redirect user
    else
      session["devise.google_data"] = request.env["omniauth.auth"].select { |k, v| k == "email" }
      redirect_to choose_profile_path(anchor: 'step-1')
    end
  end

  def failure
    redirect_to root_path
  end

end
