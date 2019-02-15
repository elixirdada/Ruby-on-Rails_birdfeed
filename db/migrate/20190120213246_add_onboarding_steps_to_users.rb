class AddOnboardingStepsToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column  :users, :onboarding_step, :integer, default: 0
    # User.all.each do |u|
    #   if u.old_id
    #     u.update(onboarding_step: 3)
    #   elsif u.terms_and_conditions && u.code_of_conduct
    #     u.update(onboarding_step: 0)
    #   end
    # end
  end
end