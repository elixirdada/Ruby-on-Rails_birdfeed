module ApplicationHelper

  def controller?(*controller)
    controller.include?(params[:controller])
  end

  def action?(*action)
    action.include?(params[:action])
  end

  def show_svg(path)
    File.open("app/assets/images/#{path}", "rb") do |file|
      raw file.read
    end
  end

  def avatar_style user
    return 'ninja-style' if user == @ninja
    return 'admin-style' if user.has_role?(:admin)
    return 'intern-style' if user.has_role?(:intern)
    return 'boss-style' if user.has_role?(:boss)
    return 'homey-style' if user.has_role?(:homey)
    return 'handler-style' if user.has_role?(:handler)
    return 'artist-style' if user.has_role?(:artist)
    return 'insider-style' if %w(monthly_insider yearly_insider).include? user.subscription_length
    if %w(monthly_vib yearly_vib monthly_old yearly_old).include? user.subscription_length
      return 'vib-style'
    end
    'chirp-style'
  end

  def user_tag user
    return 'VIB Grandfather' if user.old_id && %w(monthly_old yearly_old).include?(user.subscription_length)
    return 'Chirp Grandfather' if user.old_id
    return 'Insider' if %w(monthly_insider yearly_insider).include? user.subscription_length
    return 'VIB' if %w(monthly_vib yearly_vib).include? user.subscription_length
    'Chirp'
  end

  def subscription_length user
    return 'Monthly' if %w(monthly_insider monthly_vib).include? user.subscription_length
    return 'Yearly' if %w(yearly_vib yearly_insider).include? user.subscription_length
    return ''
  end

  def get_setting ident
    setting = SiteSetting.where(ident: ident).first

    setting.val if setting.present?
  end

  def get_setting_res ident
    setting = SiteSetting.where(ident: ident).first

    setting.res if setting.present?
  end

  def get_user_rate_for_track track
    if current_user
      @rating = Rate.where(rater_id: current_user.id, rateable_id: track.id, rateable_type: 'Track')
      @rating.any? ? @rating.first.stars.try(:round,0) : 0.0
    else
      return 0.0
    end
  end

  def correct_user_path user
    if user.has_role?(:artist)
      if !user.profile_url
        return artist_path user.id
      else
        return artist_path user.profile_url
      end
    elsif user.has_role?(:admin)
      return admin_path user
    else
      if !user.profile_url
        return user_path user.id
      else
        return user_path user.profile_url
      end
    end
  end

  def get_metadata url
    page = MetaInspector.new(url)
    { title: page.title, desc: page.description, image: page.images.best,
      video: page.meta['og:video:url'], player: page.meta['twitter:player'] }
  end

  def comment_with_meta_data text
    if match = text.match(/(http|https):(\/?\/?)[^\s]+/)
      meta_data = get_metadata(match[0])
      meta_data_html = '<strong>'+meta_data[:title].to_s+'</strong>'
      # meta_data_html += '<br>'+meta_data[:desc].try(:truncate,140).to_s if meta_data[:desc]
      if meta_data[:video].present?
        meta_data_html += '<iframe id="ytplayer" type="text/html" width="100%" height="400px" src="'+meta_data[:video]+'" frameborder="0" allowfullscreen></iframe>'
      elsif meta_data[:player].present?
        meta_data_html += '<iframe width="100%" height="300" scrolling="no" frameborder="no" allow="autoplay" src="'+meta_data[:player]+'"></iframe>'
      elsif meta_data[:image].present?
        meta_data_html += '<br><img class="feed-image" src="'+meta_data[:image].to_s+'">'
      end

      meta_data_html = '<a href="'+match[0]+'" target="_blank">'+meta_data_html+'</a>'
    end

    text.dup.gsub(URI.regexp, '<a href="\0" target="_blank">\0</a><p>'+meta_data_html.to_s+'</p>')
  end

end
