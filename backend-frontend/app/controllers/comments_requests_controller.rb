class CommentsRequestsController < ApplicationController
  
  before_action :find_comments_request, except: [:new, :create]

  def new
    @comments_request = CommentsRequest.new
  end

  def create
    request_id = params[:comments_request][:request_id]
    if current_user.creator_cases?(request_id, 'request') || current_user.is_sa? || current_user.is_admin?
       @comments_request = current_user.comments_requests.build(params_comments_request)
      if @comments_request.save
        change_state(@comments_request, 'active')
        redirect_to request_path(request_id)
      else
        render :new
      end
    else
      render :new
    end
  end

  def edit
  end

  def update
    request_id = params[:comments_request][:request_id]
    if current_user.creator_cases?(request_id, 'request') || current_user.is_sa? || current_user.is_admin?
      @comments_request.assign_attributes(params_comments_request)
      if @comments_request.save
        redirect_to request_path(request_id)
      else
        render :edit
      end
    else
      render :edit
    end
  end

  def destroy
    @comments_request.destroy
    redirect_to request_path(params[:request_id])
  end

  private
  def find_comments_request 
    @comments_request = CommentsRequest.find(params[:id])
  end

  def params_comments_request
    params.require(:comments_request).permit(:description, :request_id)
  end

  def change_state(comments_request, state)
    request = comments_request.request
    request.assign_attributes(state: state)
    request.save
  end
end
