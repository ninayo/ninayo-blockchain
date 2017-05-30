ActiveAdmin.register CallLog do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

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
