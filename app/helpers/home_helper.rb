module HomeHelper
  
  def primary_avatar name
    img = Avatarly.generate_avatar(name.parameterize, opts={size: 256})
    filepath = "public/images/#{SecureRandom.hex}.png"
    File.open(filepath, 'wb') do |f|
      f.write img
    end

    File.new filepath
  end
end
