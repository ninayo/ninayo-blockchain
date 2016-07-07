class AdLog < ActiveRecord::Base
	belongs_to :ad
	belongs_to :user
	belongs_to :event_type

	def self.summary(ad_id = nil)
		#sql = "select EXTRACT(year FROM start_time)::int AS year,  EXTRACT(month FROM start_time)::int AS month, count(id) from trips WHERE user_id = :user_id GROUP BY year, month ORDER BY year, month;"
		#sql = "select ad_id, count(id) from ad_logs WHERE event_type_id = :event_type_id GROUP BY ad_id;"
		
		#removing this for the time being, since it isnt doing anything and is an injection vulnerability
		# if ad_id
		# 	sql = "select ad_id, event_type_id, count(id) AS count from ad_logs WHERE ad_id = #{ad_id} GROUP BY ad_id, event_type_id ORDER BY ad_id, event_type_id;"
		# 	find_by_sql(sql)
		# else
		# 	sql = "select ad_id, event_type_id, count(id) AS count from ad_logs GROUP BY ad_id, event_type_id ORDER BY ad_id, event_type_id;"
		# 	find_by_sql(sql)
		# end
	end
end
