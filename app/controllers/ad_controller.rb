class AdController < ApplicationController
  ssl_required :index, :login, :validate, :logout
  before_filter :set_cache_buster
  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  def index
    login
    render :action => :login
  end

  def login
    @advertiser = Administrator.new
  end

  def validate
    session[:advertiser] = Administrator.authenticate(params[:advertiser][:username],params[:advertiser][:password])
    if session[:advertiser]
      redirect_to :action => 'campaigns'
    else
      flash[:notice] = 'Username and/or Password Incorrect.'
      redirect_to :action => 'login'
    end
  end

  def logout
    session[:advertiser] = nil
    @advertiser = nil
    redirect_to :action => 'index'
  end


end
