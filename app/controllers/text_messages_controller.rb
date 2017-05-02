class TextMessagesController < ApplicationController

    skip_before_action :verify_authenticity_token

    def create
        TextMessage.create(message_attributes)
        head :ok #need to have this or we run into errors with twilio api
    end

    def send_outgoing
        client.messages.create(
            to: to,
            from: from,
            body: body
        )
    end

    def find_for_sms_reset
    u = User.find_by(:phone_number => params[:reset_request][:phone_number])

        if !u.nil?
          u.sms_pw_reset
          redirect_to root_url, :flash => { notice: "Your PIN has been reset and sent to you via SMS" }
        else
          redirect_to(new_user_password_path, {:flash => { error: "Phone number not found, please try again" } } )
        end
    end

    private

    def client
        @client ||= Twilio::REST::Client.new
    end

    def message_attributes
        {   to: params[:To],
            from: params[:From],
            body: params[:Body]
        }
    end

end
