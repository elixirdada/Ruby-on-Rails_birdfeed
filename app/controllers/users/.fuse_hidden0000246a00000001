class Users::RegistrationsController < Devise::RegistrationsController
  
  before_action :set_notifications#, only: [:edit]
  prepend_before_action :authenticate_scope!, only: [:edit_profile, :edit_account]
  prepend_before_action :set_minimum_password_length, only: [:edit_profile, :edit_account]

  def edit_profile
    render :edit_profile
  end

  def update_profile
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    resource_updated = resource.update_without_password(account_update_params)
    yield resource if block_given?
    if resource_updated
      if is_flashing_format?
        flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
          :update_needs_confirmation : :updated
        set_flash_message :notice, flash_key
      end
      bypass_sign_in resource, scope: resource_name
      respond_with resource, location: after_update_path_for(resource)
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  def edit_account
    render :edit_account
  end

  def update_account
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    resource_updated = resource.update_with_password(account_update_params)
    yield resource if block_given?
    if resource_updated
      if is_flashing_format?
        flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
          :update_needs_confirmation : :updated
        set_flash_message :notice, flash_key
      end
      bypass_sign_in resource, scope: resource_name
      respond_with resource, location: after_update_path_for(resource)
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  protected

  def after_sign_up_path_for(resource)
    choose_profile_path(anchor: 'step-2')
  end

  def update_resource(resource, params)
    #TODO Why without password???
    resource.update_without_password(params) 
    # if resource.provider.present?
    #   resource.update_without_password(params) 
    # else
    #   resource.update_with_password(params)
    # end
  end

  private

  # def account_update_params
  #   params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :current_password, :profile_url)
  # end

  def account_update_params
    devise_parameter_sanitizer.sanitize(:account_update)
  end

end