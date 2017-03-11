# Controller for pricing pages
class PricesController < ApplicationController
  before_action :authenticate_user! 
end
