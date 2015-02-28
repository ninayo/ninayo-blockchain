class AdLog < ActiveRecord::Base
  belongs_to :ad
  belongs_to :user
  belongs_to :event_type
end
