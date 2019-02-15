module Aasm
  module User
    extend ActiveSupport::Concern

    included do
      include AASM
      enum onboarding_step: {
        set_profile: 0,
        select_membership: 1,
        accept_tos: 2,
        confirm_email: 3,
        step_1: 4,
        step_2: 5,
        step_3: 6,
        step_4: 7,
        first_message: 8,
        onboarded: 9
      }

      aasm column: :onboarding_step, enum: true, whiny_transitions: false do
        state :set_profile, initial: true
        state :select_membership
        state :accept_tos
        state :step_1
        state :step_2
        state :step_3
        state :step_4
        state :confirm_email
        state :first_message
        state :onboarded

        event :profile_completed do
          transitions from: :set_profile, to: :select_membership
        end

        event :email_confirmed do
          transitions from: :confirm_email, to: :step_1
        end

        event :step_1_completed do
          transitions from: :step_1, to: :step_2
        end

        event :step_2_completed do
          transitions from: :step_2, to: :step_3
        end

        event :step_3_completed do
          transitions from: :step_3, to: :step_4
        end
      end
    end
  end
end
