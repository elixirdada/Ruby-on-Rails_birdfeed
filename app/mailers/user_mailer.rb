class UserMailer < ActionMailer::Base

  def support_center_email email, topic, message
    to = %w(birdfeed@dirtybirdrecords.zohodesk.com birdfeedsupport@dirtybird.com)
    # to = 'birdfeed@dirtybirdrecords.zohodesk.com'
    @email = email
    @topic = topic
    @message = message
    mail(to: to, from: "birdfeedsupport@dirtybird.com", subject: 'Support Query')
  end

  def after_onboard(user)
    @user = user
    mail(to: user.email, from: "admin@dirtybird.com", subject: 'Signup Successful')
  end

  def account_cancel_mail_to_user user, name
    to = %w()
    to.push user
    @name = name
    mail(to: to, from: "birdfeedsupport@dirtybird.com", subject: 'Your Account Cancelled')
  end

  def account_cancel_mail_to_admin params, user
    to = %w(birdfeed@dirtybirdrecords.zohodesk.com)
    @email = user
    @why_cancel_account = params[:why_cancel_account]
    @your_thoughts = params[:your_thoughts]
    mail(to: to, from: "birdfeedsupport@dirtybird.com", subject: 'Account Cancelled')
  end

  def user_email_update user, name
    @email = user
    @name = name
    mail(to: @email, from: "birdfeedsupport@dirtybird.com", subject: 'Account Email Updated')
  end

  def user_password_update user, name
    @email = user
    @name = name
    mail(to: @email, from: "birdfeedsupport@dirtybird.com", subject: 'Account Password Updated')
  end
end
