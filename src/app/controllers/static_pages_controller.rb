class StaticPagesController < ApplicationController
  def home
    @lists = List.where(user: current_user).order("created_at ASC")
  end

  def help
  end

  def about
  end

  def contact
  end
end
