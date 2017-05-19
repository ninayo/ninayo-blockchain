class HelpRequest < ActiveRecord::Base
  validates :request_type, :body, :phone_number, presence: true, on: :create
  validates :phone_number, numericality: true
  belongs_to :user
end
