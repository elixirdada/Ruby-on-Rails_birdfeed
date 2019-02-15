ActiveAdmin.register Badge do
  permit_params :name, :points, :image, :message, :badge_kind_id,
    badge_points_weights_attributes: [:id, :badge_id, :badge_action_type_id, 
    :value, :condition, :active, :_destroy], 
    badge_dependencies_attributes: [:id, :badge_id, :depended_badge_id, :_destroy]

  index do
    column :name
    column :badge_kind
    column :message
    actions
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.actions
    
    f.inputs do
      f.input :badge_kind
      f.input :name
      f.input :image
      f.input :points if f.object.badge_kind && f.object.badge_kind.ident == 'leaderboard_points'
    end
    f.inputs do
      
      BadgeActionType.where(badge_kind_id: f.object.badge_kind_id).map do |type|
        unless f.object.badge_points_weights.pluck(:badge_action_type_id).include?(type.id)
          f.object.badge_points_weights.new(badge_action_type_id: type.id)
        end
      end

      f.has_many :badge_points_weights, new_record: false do |a|
        a.input :badge_action_type_id, as: :hidden, value: a.object.badge_action_type_id

        name = ''
        points = nil
        count_to_achieve = 1

        if a.object.badge_action_type.present?
          name = a.object.badge_action_type.name
          points = a.object.badge_action_type.points || 0
          count_to_achieve = a.object.badge_action_type.count_to_achieve
          if name.match(/role/)
            hint = "Action: <b>#{name}</b>"
          else
            hint = "Action: <b>#{name}</b> / #{points} points / #{count_to_achieve} to achieve"
          end
        end

        a.input :active, 
            hint: hint.try(:html_safe)

        a.actions
      end
    end

    f.inputs do
      f.has_many :badge_dependencies do |c|
        c.input :depended_badge
        c.input :badge_id, :input_html => { :value => f.object.id }, as: :hidden
      end
    end

    f.inputs do
      f.input :message
    end

    f.actions
  end

end
