class PostImportsController < ApplicationController

  before_action :authenticate_user!
  before_action :check_role

  def new
    @post_import = PostImport.new
  end

  def create
    @post_import = PostImport.new(params[:post_import])
    if @post_import.save
      redirect_to new_post_import_url, notice: "All items imported successfully"
    else
      render :new
    end
  end

  protected

  def check_role
    unless admin_user?
      redirect_to root_url, alert: "Permission denied"
    end
  end

end
