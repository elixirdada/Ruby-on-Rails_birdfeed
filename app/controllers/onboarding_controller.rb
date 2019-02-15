class OnboardingController < ApplicationController
  before_action :authenticate_user!, :onboarding_status
  before_action :set_notifications

  def index
  end

  def step_2
    redirect_back(fallback_location: '/') if @member == 'CHIRP FREE'
    current_user.step_1_completed!
  end

  def step_3
    redirect_back(fallback_location: '/') unless @style_type == "vib-style"
    current_user.step_2_completed!
  end

  def step_4
    redirect_back(fallback_location: '/') unless @style_type == "vib-style"
    current_user.step_3_completed!
  end

  def onboarding_complete
    if current_user.id.to_s == params[:onboarding_id]
      current_user.onboarded!
      redirect_to home_path
    else
      flash[:alert] = "An error occured!"
      redirect_to onboarding_index_path
    end
  end

  private
  def onboarding_status
    @style_type = avatar_style(current_user)
    @member = user_tag(current_user)
    redirect_back(fallback_location: '/') if current_user.onboarded?
  end
end
