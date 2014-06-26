class UsersController < ApplicationController

  before_action :signed_in_user, only: [:index, :edit, :update, :destroy] #before the actions edit and update, run signed_in_user defined below
  before_action :correct_user, only: [:edit, :update] #before doing anything, check that we have the right user, otherwise redirect to root
  before_action :admin_user, only: [:destroy] #note: square brackets are optional here

  def new
  	@user = User.new
  end

  def show
  	@user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  def create
  	@user = User.new(user_params)
  	if @user.save
      sign_in @user #so the user is automatically signed in upon creating an account
  		flash[:success] = "Welcome to the Sample App" #sets key "success" to display a message on redirect
  		redirect_to @user #redirects to user_path(@user)
  	else
  		render "new"
  	end
  end

  def edit #just to create the view - the update action does all the actual patching work afterwards
  end

  def update
    if @user.update_attributes(user_params) #try to update with the supplied params (email, password, etc)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def index
    @users = User.paginate(page: params[:page]) #params page is generated automatically by will_paginate - if it's nil
    # (as I think it is when you first hit "users"), it gives the first page.
    #@users = User.all #stores all users in an instance variable, which is available in all the views (edit: changed for pagination)
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  private
  def user_params #private method, to make sure we don't get screwed by rails security measures
  	params.require(:user).permit(:name, :email, :password, :password_confirmation) #notice that :admin is NOT present
  end


  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end

  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end

end


