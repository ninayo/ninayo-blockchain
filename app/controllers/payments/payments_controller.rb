require 'net/http'
# tigopesa payment api for great justice
class PaymentsController < ApplicationController
  before_action :authenticate_user!

  TIGO_PESA_URL = URI('https://securesandbox.tigo.com/v1/')
  CLIENT_ID     = ENV['TIGO_CLIENT_ID']
  CLIENT_SECRET = ENV['TIGO_CLIENT_SECRET']

  # probably wanna module most of this create/send/response stuff out
  def request_tigo_access_token
    target_path = 'oauth/generate/accesstoken?grant_type=client_credentials'
    uri = TIGO_PESA_URL + target_path
    req = Net::HTTP::Post.new(uri)
    req.set_form_data('client_id' => CLIENT_ID,
                      'client_secret' => CLIENT_SECRET)

    res = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }

    @tigo_access_token = JSON.parse(res.body)['accessToken']
  end

  # direct transfer between two users
  # called a deposit remittance in the docs, pg 25
  def transfer_money_directly(sender, receiver, amount)
    target_path = 'tigo/mfs/depositRemittance'
    uri = TIGO_PESA_URL + target_path
    req = Net::HTTP::Post.new(uri)
    req.set_content_type('application/json')
    req['accessToken'] = @tigo_access_token

    request_params = {
      'transactionRefId' => 'whatever_arbitrary_string',
      'PaymentAggregator' => { 'account' => 'str_mfs_account_number',
                               'pin' => 'str_mfs_account_pin',
                               'id' => 'str_mfs_account_name' },

      'Sender' => { 'firstName' => sender.name,
                    'lastName' => sender.name,
                    'msisdn' => sender.phone_number,
                    'emailAddress' => sender.email },

      'ReceivingSubscriber' => { 'account' => receiver.phone_number,
                                 'countryCallingCode' => 255,
                                 'countryCode' => 'TZA',
                                 'firstName' => receiver.name,
                                 'lastName' => receiver.name },

      'OriginPayment' => { 'amount' => amount,
                           'currencyCode' => 'TZS',
                           'tax' => 'float_transaction_tax',
                           'fee' => 'float_transaction_fee' },

      'verificationRequest' => false,
      'sendTextMessage' => true,

      'LocalPayment' => { 'amount' => amount,
                          'currencyCode' => 'TZS' }
    }

    req.body = request_params
    res = Net::HTTP.start(uri.hostname, uri.post) { |http| http.request(req) }

    @transaction_response = JSON.parse(res)
  end

  def payment_auth_redirect # generate redirect to tigo payment auth page
    target_path = 'tigo/payment-auth/authorize'
    uri = TIGO_PESA_URL + target_path
    req = Net::HTTP::Post.new(uri)
    req.set_content_type('application/json')
    req['accessToken'] = @tigo_access_token

    request_params = {
      'MasterMerchant' => { 'account' => 'str_mfs_account_number',
                            'pin' => 'str_mfs_account_pin',
                            'id' => 'str_mfs_account_name' },

      'Merchant' => { 'reference' => 'NINAYO.COM',
                      'fee' => 0.0,
                      'currencyCode' => 'TZS' },

      'Subscriber' => { 'account' => 'msisdn_to_debit',
                        'countryCode' => '255',
                        'country' => 'TZA',
                        'firstName' => 'str_first_name',
                        'lastName' => 'str_last_name',
                        'emailId' => 'str_email_addr' },

      'redirectUri' => 'str_whatever_url_after_payment',
      'callbackUri' => 'str_result_callback_uri_optional',
      'language' => 'SWA',
      'terminalId' => '', # optional, dunno what this is
      'originPayment' => { 'amount' => float_transaction_amount,
                           'currencyCode' => 'TZS',
                           'tax' => float_transaction_tax,
                           'fee' => float_fee_charged_to_subscriber },

      'LocalPayment' => { 'amount' => float_transaction_amount,
                          'currencyCode' => 'TZS' },

      'transactionRefId' => 'str_unique_id' # presumably to be stored in our db
    }

    req.body = request_params

    res = Net::HTTP.start(uri.hostname, uri.post) { |http| http.request(req) }

    @transaction_response = JSON.parse(res)
    @ref_id = @transaction_response['transactionRefId'] # should be what we sent
    @auth_code = @transaction_response['authCode']

    @redirect_url = @transaction_response['redirectUrl']
  end

  def system_status
    # get current heartbeat status of tigo payment gateway
    # any number other than 0 indicates a problem desc in ['statusDescription']
    # probably want to set this as a before_action so as not to waste any time
    # maybe even run it on backend every so often to enable/disable payments
    target_path = 'tigo/systemstatus'
    uri = TIGO_PESA_URL + target_path
    req = Net::HTTP::Get.new(uri)

    res = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }

    @tigo_status = JSON.parse(res)['tigoSecureStatusCode']
  end

  def validate_mfs_account(user) # check if target user has valid mfs account
    target_path = 'tigo/mfs/validateMFSAccount'
    uri = TIGO_PESA_URL + target_path
    req = Net::HTTP::Post.new(uri)
    req.set_content_type('application/json')
    req['accessToken'] = @tigo_access_token

    req.body = {
      'transactionRefId' => 'str_transaction_ref',
      'ReceivingSubscriber' => {
        'account' => user.phone_number,
        'countryCallingCode' => 255,
        'countryCode' => 'TZA',
        'firstName' => user.name,
        'lastName' => user.name
      }
    }

    res = Net::HTTP.start(uri.hostname, uri.post) { |http| http.request(req) }
    # for some reason tigo returns the t/f as a string
    account_valid = JSON.parse(res)['validateMFSAccountResponse']['ResponseBody']['validMFSAccount']
    ActiveRecord::Type::Boolean.new.type_cast_from_database(account_valid)
  end
end
