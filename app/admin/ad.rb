ActiveAdmin.register Ad do
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

  permit_params :crop_type, :region_id, :district_id, :ward_id, :village,
                :price, :volume, :volume_unit, :published_at, :archived_at

  config.per_page = 25

  index pagination_total: false do
    column :id
    column :ad_type
    column :crop_type
    column :price
    column :volume
    column :volume_unit
    column :user
    column :region
    column :village
    column :published_at
    actions
  end

  # Filters
  filter :crop_type, as: :check_boxes, collection: proc { CropType.all }
  filter :region, as: :select, collection: proc { Region.all }
  filter :published_at, as: :date_range

  remove_filter :description
  remove_filter :updated_at
  remove_filter :status
  remove_filter :lat
  remove_filter :lng
  remove_filter :final_price
  remove_filter :archived_at
  remove_filter :buyer_id
  remove_filter :buyer_price
  remove_filter :negotiable
  remove_filter :transport_type
end
