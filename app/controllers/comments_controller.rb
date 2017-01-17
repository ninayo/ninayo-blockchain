class CommentsController < ApplicationController

  def new
    @comment = Comment.new
  end

  def create
    @comment = Comment.new(comment_params)
    @comment.author_id = current_user.id
    @comment.ad_id = params[:ad_id]

    if @comment.save
      redirect_to :back, notice: "Asante!"
    else
      redirect_to :back, notice: @comment.errors.full_messages
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end
end