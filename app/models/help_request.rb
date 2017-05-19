class HelpRequest < ActiveRecord::Base
  validates :request_type, :body, :phone_number, presence: true, on: :create
  validates :phone_number, numericality: true
  validates :phone_number, length: { is: 10 }
  belongs_to :user
end
