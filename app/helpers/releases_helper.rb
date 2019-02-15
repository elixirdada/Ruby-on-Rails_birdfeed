module ReleasesHelper
  
  def releases_query releases, page = 1, per_page = 16, all_with_previous = true
    page = page.to_i
    per_page = per_page.to_i

    if all_with_previous
      @limit = page * per_page
      @offset = 0
    else
      @limit = per_page
      @offset = (page - 1) * per_page
    end

    @releases = releases.limit(@limit).offset(@offset)
  end

  
end


