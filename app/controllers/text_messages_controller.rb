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
