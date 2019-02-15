class BirdOldDb < ActiveRecord::Base
  establish_connection(ENV['bird_old'])
end
