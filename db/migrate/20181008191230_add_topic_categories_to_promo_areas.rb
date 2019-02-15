class AddTopicCategoriesToPromoAreas < ActiveRecord::Migration[5.1]
	def up
		add_reference :promo_areas, :topic_category, foreign_key: true
	end
	
	def down
		
	end
end
