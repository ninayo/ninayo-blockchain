class PostImport

  include ActiveModel::Model #not actually a rails model but we include some methods

  attr_accessor :file #uploaded file gets stored under temp path, garbage collected, no need to worry about name

  def initialize(attributes = {})
    attributes.each { |name, value| send("#{name}=", value) }
  end

  def persisted?
    false
  end

  def save

    if imported_posts.map(&:valid?).all?
      imported_posts.each(&:save!)
      true
    else
      imported_posts.each_with_index do |post, index|
        post.errors.full_messages.each do |message|
          errors.add :base, "Row #{index+2}: #{message}"
        end
      end
      false
    end

  end

  def imported_posts
    @imported_posts ||= load_imported_posts
  end

  def load_imported_posts #dear sweet mother of mercy please refactor this godforsaken method
    spreadsheet = open_spreadsheet
    header = spreadsheet.row(2)
    
    (3..spreadsheet.last_row).map do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]

      user = User.where(:phone_number => row["Simu #"]) #match against phone number, first or create
                  .first_or_create!(:agreement => true, 
                                  :name => row["Jina"].titleize,
                                  :email => row["Email (hiari)"] || "no_email#{rand(9999999)}@ninayo.com",
                                  :password => SecureRandom.urlsafe_base64(60), #set random pw for easy conversion
                                  :village => row["Mitaa/Kijiji (hiari)"],
                                  :region_id => Region.find_by_name(row["Mkoa"]).id,
                                  :district_id => District.find_by_name(row["Wilaya"]).id,
                                  :ward_id => Ward.find_by_name(row["Wodi"]).id)
      user.update!(:name => row["Jina"].titleize) #run another check in case we got a name for known user this time
      
      #TODO: archive old user posts of same crop when we get an updated version to keep things tidy

      post = Ad.new #this could be done more concisely with .attributes or a helper but works for now
      post.description    = row["Maelezo (hiari)"]
      post.price          = row["Uza"]
      post.volume         = row["Ukubwa"]
      post.volume_unit    = row["Unit"].downcase
      post.crop_type_id   = CropType.find_by_name_sw(row["Mazao"].titleize).id #TODO: search by en name as well 
      post.region_id      = user.region_id
      post.village        = row["Mitaa/Kijiji (hiari)"] || "" #we have to have a village, but it can be anything
      post.lat            = user.district.lat #all users registered through this method necessarily have districts
      post.lng            = user.district.lon
      post.user_id        = user.id #automatically append this ad to user in question
      post.ad_type        = 0 #TODO: post ads with each ad_type, 0 = sell 1 = buy
      post.status         = 1 #auto-publish
      post
    end

  end

  def open_spreadsheet
    case File.extname(file.original_filename)
    when ".csv" then Roo::Csv.new(file.path, packed: false, file_warning: :ignore)
    when ".xls" then Roo::Excel.new(file.path, packed: false, file_warning: :ignore)
    when ".xlsx" then Roo::Excelx.new(file.path, packed: false, file_warning: :ignore)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end

end