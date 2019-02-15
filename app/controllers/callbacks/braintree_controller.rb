class Callbacks::BraintreeController < ApplicationController
  protect_from_forgery with: :null_session, only: [:analytics_notify]

  def update_cc
    payment_method = Braintree::PaymentMethod.update(
      current_user.braintree_subscription.payment_method_token,
      payment_method_nonce: params[:payment_method_nonce]
    )

    if payment_method.success?
      flash[:notice] = 'Payment method updated.'
    else
      if payment_method.credit_card_verification
        flash[:alert] = 'Failed to update payment method. Please recheck your credit card number'
      else
        flash[:alert] = 'Failed to update payment method. You cannot currently change from Credit Card to PayPal billing. If you are still having issues, contact support.'
      end
    end
    redirect_back fallback_location: '/'
  end

  def nonce
    #buy more credits logic
    if params[:credits_count].present?
      unless current_user.braintree_customer
        flash[:alert] = 'You should be subscribed first'
        redirect_to choose_profile_path and return
      end

      if params[:payment_method_nonce].present? && current_user.braintree_subscription
        payment_method = Braintree::PaymentMethod.update(
          current_user.braintree_subscription.payment_method_token,
          payment_method_nonce: params[:payment_method_nonce]
        )

        unless payment_method.success?
          if payment_method.credit_card_verification
            flash[:alert] = 'Failed to update payment method. Please recheck your credit card number.'
          else
            flash[:alert] = 'Failed to update payment method. You cannot currently change from Credit Card to PayPal billing. If you are still having issues, contact support.'
          end
          redirect_to choose_profile_path and return
        end
      end

      if params[:credits_count] == '13'
        amount = 12
      else
        amount = params[:credits_count]
      end

      result = Braintree::Transaction.sale(
        :amount => amount.to_f,
        :payment_method_token => current_user.braintree_customer.payment_methods[0].token,
        :options => {
          :submit_for_settlement => true
        }
      )

      if result.success?
        current_user.increment!(:download_credits, params[:credits_count].to_i)

        if payment_method.present?
          flash[:notice] = "#{params[:credits_count]} credits was added"
        else
          flash[:notice] = "Payment method was updated and #{params[:credits_count]} credits was added"
        end
      else
        if result.credit_card_verification
          flash[:alert] = 'Error when adding credits. Please recheck your credit card number.'
        else
          flash[:alert] = 'Error when adding credits. If unexpected, contact support.'
        end
        redirect_to get_more_credits_path and return
      end

      notification = "Order!"
      notification << " #{current_user.try(:name)}(#{current_user.try(:id)})"
      notification << "subscr: #{params[:subscription]}" if params[:subscription].present?
      notification << "subscr: #{params[:credits_count]}" if params[:credits_count].present?
      SLACK.ping notification

      redirect_to get_more_credits_path( success: true ) and return
    end

    download_credits = 0
    if params[:subscription] == 'yearly_vib'
      plan_id = ENV['BRAINTREE_YEARLY_PLAN_VIB_ID']
      download_credits = 30
    elsif params[:subscription] == 'yearly_insider'
      plan_id = ENV['BRAINTREE_YEARLY_PLAN_INSIDER_ID']
    elsif params[:subscription] == 'monthly_insider'
      plan_id = ENV['BRAINTREE_MONTHLY_PLAN_INSIDER_ID']
    elsif params[:subscription] == 'monthly_vib'
      plan_id = ENV['BRAINTREE_MONTHLY_PLAN_VIB_ID']
      download_credits = 30
    else
      plan_id = nil
    end

    if current_user.braintree_subscription
      if params[:payment_method_nonce].present?
        payment_method = Braintree::PaymentMethod.update(
          current_user.braintree_subscription.payment_method_token,
          payment_method_nonce: params[:payment_method_nonce]
        )

        if payment_method.success?
          flash[:notice] = 'Payment method updated.'
        else
          if payment_method.credit_card_verification
            flash[:alert] = 'Failed to update payment method. Please recheck your credit card number'
          else
            flash[:alert] = 'Failed to update payment method. You cannot currently change from Credit Card to PayPal billing. If you are still having issues, contact support.'
          end
          redirect_to choose_profile_path and return
        end
      end

      if params[:subscription].present?
        unless plan_id
          throw "Couldn't find plan for subscription #{params[:subscription]}"
        end

        Braintree::Subscription.cancel(current_user.braintree_subscription_id)

        result = Braintree::Subscription.create(
          plan_id: plan_id,
          payment_method_token: current_user.braintree_customer.payment_methods[0].token
        )

        if result.success?
          current_user.update_attributes(
            braintree_subscription_id: result.subscription.id,
            subscription_started_at: Date.today,
            subscription_length: params[:subscription],
            download_credits: download_credits
          )

          if result.subscription.trial_period
            current_user.update_attributes(braintree_subscription_expires_at: result.subscription.next_billing_date.to_date - 1)
          else
            current_user.update_attributes(braintree_subscription_expires_at: result.subscription.paid_through_date)
          end

          flash[:notice] = 'Subscription type updated.'
          redirect_to root_path and return
          #TODO redirect to success page (payment method and/or subscription type)
        else
          if result.credit_card_verification
            flash[:alert] = 'Failed to change Subscription. Please check your credit card number.'
          else
            flash[:alert] = 'Failed to change Subscription. If unexpected, contact support.'
          end
          redirect_to choose_profile_path and return
        end
      end
    end

    if params[:payment_method_nonce].blank?
      SLACK.ping "Missing Nonce on Callback userId #{current_user.id}"

      flash[:alert] = 'Failed to process payment. Please double check your information and try again. You have not yet been charged.'
      redirect_to choose_profile_path and return
    end

    current_user.update_attributes(terms_and_conditions: true, code_of_conduct: true)

    # Create or find customer
    unless current_user.braintree_customer
      # Create Customer and store their Payment Method
      result = Braintree::Customer.create(
        first_name: current_user.first_name,
        last_name: current_user.last_name,
        email: current_user.email,
        payment_method_nonce: params[:payment_method_nonce]
      )
      if result.success?
        current_user.update(braintree_customer_id: result.customer.id)
      else
        if result.credit_card_verification
          flash[:alert] = 'Transaction failed. Please recheck your credit card number.'
        else
          flash[:alert] = 'Transaction failed. If unexpected, contact support.'
        end
        redirect_to choose_profile_path and return
      end
    end

    # Create or find Subscription
    if current_user.braintree_subscription
      result = Braintree::PaymentMethod.update(
        current_user.braintree_subscription.payment_method_token,
        payment_method_nonce: params[:payment_method_nonce]
      )
      if result.success?
        flash[:notice] = 'Payment method updated.'
        redirect_to root_path and return
      else
        if result.credit_card_verification
          flash[:alert] = 'Failed to update payment method. Please recheck your credit card number.'
        else
          flash[:alert] = 'Failed to update payment method. If you are still having issues, contact support.'
        end
        redirect_to choose_profile_path and return
      end
    else
      unless plan_id
        throw "Couldn't find plan for subscription #{params[:subscription]}"
      end

      result = Braintree::Subscription.create(
        plan_id: plan_id,
        payment_method_token: current_user.braintree_customer.payment_methods[0].token
      )

      if result.success?
        current_user.update_attributes(
          braintree_subscription_id: result.subscription.id,
          subscription_started_at: Date.today,
          subscription_length: params[:subscription],
          download_credits: download_credits
        )
          # subscribed: true,

        if result.subscription.trial_period
          current_user.update_attributes(braintree_subscription_expires_at: result.subscription.next_billing_date.to_date - 1)
        else
          current_user.update_attributes(braintree_subscription_expires_at: result.subscription.paid_through_date)
        end
      else
        if result.credit_card_verification
          flash[:alert] = 'Failed to create new Subscription record. Please recheck your credit card number.'
        else
          flash[:alert] = 'Failed to create new Subscription record. If unexpected, contact support.'
        end
        redirect_to choose_profile_path and return
      end
    end

    flash[:notice] = 'Subscription Created'

    begin
      payment_method = if current_user.braintree_customer.payment_methods.first.respond_to?(:last_4)
                         'credit_card'
                       else
                         'paypal'
                       end
    rescue => e
      # Honeybadger.notify(e)
      # payment_method = 'undetermined'
    end

    if params[:subscription] == 'yearly_vib' || params[:subscription] == 'monthly_vib'
      member = 'vib member'
    elsif params[:subscription] == 'yearly_insider' || params[:subscription] == 'monthly_insider'
      member = 'insider'
    end
    current_user.confirm_email! if member.present?
    UserMailer.after_onboard(current_user).deliver
    redirect_to success_signup_path(member: member ) and return
  end

  def analytics_notify
    webhook_notification = Braintree::WebhookNotification.parse(
      params[:bt_signature],
      params[:bt_payload]
    )
    user = User.where(braintree_subscription_id: webhook_notification.subscripption.id).first

    if webhook_notification.kind == Braintree::WebhookNotification::Kind::SubscriptionChargedUnsuccessfully
    elsif webhook_notification.kind == Braintree::WebhookNotification::Kind::SubscriptionChargedSuccessfully
    end
    render body: '', status: 200
  end
end
