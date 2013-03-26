class AdminController < ApplicationController
  ssl_required :index, :login, :validate, :logout, :users, :user, :locations, :location, :tags, :tag, :users_for_locations, :users_for_tag, :clear_suspect, :make_abusive
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
    @admin = Administrator.new
  end

  def validate
    session[:admin] = Administrator.authenticate(params[:admin][:username],params[:admin][:password])
    if session[:admin]
      redirect_to :action => 'tags'
    else
      flash[:notice] = 'Username and/or Password Incorrect.'
      redirect_to :action => 'login'
    end
  end

  def logout
    session[:admin] = nil
    @admin = nil
    redirect_to :action => 'index'
  end

  def users
    if(session[:admin])
      @users = User.all;
    else
      redirect_to :action => 'index'
    end
  end

  def user
    if(session[:admin])
      @user = User.find(params[:id]);
    else
      redirect_to :action => 'index'
    end
  end

  def locations
    if(session[:admin])
      @locations = Location.all;
    else
      redirect_to :action => 'index'
    end
  end

  def location
    if(session[:admin])
      @location = Location.find(params[:id]);
    else
      redirect_to :action => 'index'
    end
  end

  def tags
    if(session[:admin])
      @tags = Tag.find(:all, :order => "suspect desc, abusive asc, tag asc");
    else
      redirect_to :action => 'index'
    end
  end

  def tag
    if(session[:admin])
      @tag = Tag.find(params[:id]);
    else
      redirect_to :action => 'index'
    end
  end

  def users_for_location
    if(session[:admin])
      @location = Location.find(params[:id])

      @users_for_location = Set.new;
      @location.references.each {|r|
        r.users.each {|u|
          @users_for_location.add(u);
        }
      }
    else
      redirect_to :action => 'index'
    end
  end

  def users_for_tag
    if(session[:admin])
      @tag = Tag.find(params[:id])

      @users_for_tag = Set.new;
      @tag.references.each {|r|
        r.users.each {|u|
          @users_for_tag.add(u);
        }
      }
    else
      redirect_to :action => 'index'
    end
  end

  def clear_suspect
    if(session[:admin])
      @tag = Tag.find(params[:id]);
      @tag.suspect = false;
      @tag.save
      redirect_to :action => :tags
    else
      redirect_to :action => 'index'
    end
  end

  def make_abusive
    if(session[:admin])
      @tag = Tag.find(params[:id]);
      @tag.suspect = false;
      @tag.abusive = true;
      @tag.save
      redirect_to :action => :tags
    else
      redirect_to :action => 'index'
    end
  end
end
