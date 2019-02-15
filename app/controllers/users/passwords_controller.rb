class Users::PasswordsController < Devise::PasswordsController

	def link_sent
		self.resource = resource_class.new
	end

  protected
  def after_sending_reset_password_instructions_path_for(resource_name)
    usr_link_sent_path
  end
end