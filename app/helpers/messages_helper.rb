#TODO: refactor so this isn't N+1; the pick from a list setup is terrible anyway

module MessagesHelper
  def recipients_options
    s = ''
    User.all.each do |user|
      s << "<option value='#{user.id}'>#{user.name}</option>"
    end
    s.html_safe
  end
end