class TextLog < ActiveRecord::Base

  belongs_to :sender, :class_name => "User", :foreign_key => "sender_id"
  belongs_to :receiver, :class_name => "User", :foreign_key => "receiver_id"
  belongs_to :ad
  belongs_to :region, through: :ad
  belongs_to :district, through: :ad

end