namespace :getstream do
  desc 'Adds sheduled releases and announcements to the feed when time comes.'
  task check_schedule: :environment do
    Release.all.each do |release|
      if release.release_date <= DateTime.now && release.published_at.blank?
        release.add_to_general_feed
      end
    end

    Announcement.all.each do |announcement|
      if announcement.release_date <= DateTime.now && announcement.published_at.blank?
        announcement.add_to_general_feed
      end
    end
  end
end
