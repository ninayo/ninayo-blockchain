class Comment < ActiveRecord::Base
  belongs_to :author, class_name: 'User', foreign_key: 'author_id'
  belongs_to :ad

  validates :body, :ad_id, :author_id, presence: true, on: :create
  validates :body, length: { minimum: 2 }, on: :create
end