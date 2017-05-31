class CallLog < ActiveRecord::Base
  belongs_to :caller, class_name: 'User', foreign_key: 'caller_id'
  belongs_to :receiver, class_name: 'User', foreign_key: 'receiver_id'
  belongs_to :ad
  delegate :region, to: :ad, allow_nil: true
end
