class NotoficationController < ApplicationController

	def create
	end

	def update
		@notification = Notification.find params[:id]
    if @notification.update(notification_params)
    	redirect_to root_path
    else
    	redirect_to usr_notifications_path
    end
	end

private
	
	def notification_params 
      	params.require(:notification).permit(:sounds_option) 
	end
end