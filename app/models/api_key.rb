class ApiKey < ActiveRecord::Base

  before_create :generate_access_token

  def generate_access_token
    begin
      self.access_token = SecureRandom.hex
    end while self.class.exists?(access_token: access_token)
  end

end

#a new api key will need to be generated for every additional api client. right now there's only one for tigo