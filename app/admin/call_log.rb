ActiveAdmin.register CallLog do
  config.per_page = 25

  index pagination_total: false do
    column :ad_id
    column :caller
    column :receiver
    column :created_at
  end

  remove_filter :caller
  remove_filter :receiver
  remove_filter :ad
  remove_filter :updated_at
end
