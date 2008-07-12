class UsersController < ApplicationController 
layout "basic"
before_filter :admin_only, :only=>["show", "destroy"]
  
  def show
   # redirect_back_or_default('/') if current_user.not_tyler?    
    @users = User.find(:all) 
  end
  
  def new
  end

  def create
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with 
    # request forgery protection.
    # uncomment at your own risk
    # reset_session  
    if params[:planet].downcase.strip == "earth"
      @user = User.new(params[:user])
      @user.save 
      if @user.errors.empty? 
        self.current_user = @user
        redirect_back_or_default('/')
        flash[:notice] = "Thanks for signing up!"
      else      
        @render=true
      end
    else
      @render=true
      @user = User.new(params[:user])
      flash[:notice] = "you don't appear to be human...if you are, please try again"
    end
     render :action => 'new' if @render
  end

  def reset_password
    #
  end
  
  def forgot_password
    #generate reset code
    #store it
    #send email
  end

  
  def destroy
    @user = User.find(params[:id])
    @user.destroy
    flash[:notice] = "User destroyed"
    redirect_to user_path
  end



end
