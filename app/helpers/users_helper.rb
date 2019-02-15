module UsersHelper

  def leaderboard_query query, page = 1, per_page = 9, all = true
    page = page.to_i
    per_page = per_page.to_i

    if all
      @limit = page * per_page
      @offset = 0
    else
      @limit = per_page
      @offset = (page - 1) * per_page
    end

    if query == 'leaders'
      users_by_points @limit, @offset
    else
      query.limit(@limit).offset(@offset)
    end
  end

  def user_position user
    unless user.has_role?(:admin)
      i = users_by_points.map{ |u| u['id'] }.index(user.id)
      return "-" if i.blank?
      i + 1
    end
  end

  private

    def users_by_points limit=nil, offset=nil
      points = "(SELECT SUM(value) FROM badge_points WHERE user_id = users.id AND users.subscription_length > 0)"

      fans = "LEFT OUTER JOIN users_roles ON (users_roles.user_id = users.id) LEFT OUTER JOIN roles ON (roles.id = users_roles.role_id)"

      sql = "SELECT users.id, users.created_at, #{points} as total FROM users #{fans} WHERE (roles.name != 'admin' AND roles.name != 'artist' AND roles.name != 'intern'  AND roles.name != 'boss') OR roles.id IS NULL ORDER BY total DESC NULLS LAST, users.created_at ASC, users.id ASC"

      sql = sql + " LIMIT #{limit}" if limit
      sql = sql + " OFFSET #{offset}" if offset

      ActiveRecord::Base.connection.execute(sql)
    end
end
