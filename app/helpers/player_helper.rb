module PlayerHelper
  
  def header_image_details user
    if !user.header
      case avatar_style(user)
        when 'ninja-style'
          image_title = "Ninja Bacon Main"
          image = 'headers/ninja-bacon.jpg'
        when 'admin-style'
          image_title = "Management Main"
          image = 'headers/admin-admin.jpg'
        when 'boss-style'
          image_title = "Boss Main"
          image = 'headers/bossbird.jpg'
        when 'intern-style'
          image_title = "Intern Main"
          image = 'headers/Intern.jpg'
        when 'artist-style'
          image_title = "Artist Main"
          image = 'headers/artist-bird.jpg'
        when 'handler-style'
          image_title = "Handler Main"
          image = 'headers/handler-bird.jpg'
        when 'insider-style'
          image_title = "Insider Main"
          image = 'headers/Insider_bird.jpg'
        when 'vib-style'
          image_title = "VIB Main"
          image = 'headers/VIB-bird.jpg'
        when 'homey-style'
          image_title = "Homey Main"
          image = 'headers/Homey-Bird.jpg'
      else
        image = 'headers/chirp_bird.jpg'
        image_title = "Chirp Main"
      end
    else
      image = user.header.url
      image_title = "Capital Main"
    end
    return image, image_title
  end
end
