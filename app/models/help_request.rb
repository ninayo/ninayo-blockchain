# help request model for submissions through the help form
class HelpRequest < ActiveRecord::Base
  validates :request_type, :body, :phone_number, presence: true, on: :create
  validates :phone_number, numericality: true
  validates :phone_number, length: { is: 10 }
  belongs_to :user

  after_create :send_notification_email

  enum request_type: [:seller_help, :buyer_help, :general_help, :report_problem]

  def send_notification_email
    UserMailer.help_request(self).deliver
  end
end
