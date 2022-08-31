class ListsController < ApplicationController
  before_action :logged_in_user, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_list, only: [:edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update, :destroy]

  def new
    @list = List.new
  end

  def create
    @list = current_user.lists.build(list_params)
    if @list.save
      redirect_to :root
    else
      render action: 'new'
    end
  end
  
  def edit
  end
  
  def update
    if @list.update(list_params)
      flash[:success] = "The list updated"
      redirect_to(root_url)
    else
      render 'edit'
    end
  end

  def destroy
    @list.destroy
    redirect_to(root_url)
  end

  private
    def list_params
      params.require(:list).permit(:content).merge(user: current_user)
    end
    
    def set_list
      @list = List.find_by(id: params[:id])
    end

    def correct_user
      @list = current_user.lists.find_by(id: params[:id])
      redirect_to root_url if @list.nil?
    end
end
