module Textable
  extend ActiveSupport::Concern

  def twilio_init
    @twilio_number = ENV['TWILIO_NUMBER']
    @outgoing_num = format_number(self.phone_number)
    @client = Twilio::REST::Client.new(ENV['TWILIO_SID'], ENV['TWILIO_AUTH_TOKEN'])
  end

  def send_sms(message)
    twilio_init
    payload = @client.messages.create(
      from: @twilio_number,
      to: @outgoing_num,
      body: message
    )
  end

  def format_number(num)
    unless num[0..3] == "+255"
      num = "+255" + num
    end
  end

end
