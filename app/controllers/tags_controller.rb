class TagsController < ApplicationController
  require 'Result'

  # TODO: Remove skip_before_filter before deployment
  skip_before_filter :verify_authenticity_token

  #
  # create
  #
  def create
    @current_time_block = Reference.time_to_time_block(Time.now);

    @notify_admin_of_suspect = false;

    @user_id = params[:uid];
    @existing_user = User.find(:first, :conditions => ["uid = ?", @user_id]);
    @user_valid = false;
    if(@existing_user.nil?)
      @user = User.create(:uid => @user_id);
      if @user.save
        @user_valid = true;
      end
    else
      @user = @existing_user;
      @user_valid = true;
    end

    @roots = AbusiveRoot.all;

    # Convert lat/lon to float and round to 1/1000
    @lat = params[:lat].to_f.round(3);
    @lon = params[:lon].to_f.round(3);

    # Parse comma separated list of tags
    @cst = params[:tags];
    if(!@cst.nil? && @cst.length > 0)
      # Convert all tags to lowercase
      @cst = @cst.downcase;

      @rg_tag = @cst.split(',');
      @rg_tag.collect! {|t|
        t.strip;
        t.gsub(/[^0-9a-z ]/i, '')
      }
      @rg_tag = @rg_tag.delete_if {|t|
        t.length == 0
      }

      # Is this an existing location in the database?
      @existing_loc = Location.find(:first, :conditions => ["lat = ? and lon = ?", @lat, @lon]);
      if(!@existing_loc.nil?)
        # This is an existing location, parse tags
        # If there are any new tags, add them to the database
        @rg_tag.each {|t|
          # Is this tag already in the database?
          @existing_tag = Tag.find(:first, :conditions => ["tag=?", t]);
          if(@existing_tag.nil?)
            # New tag, add to database
            @tag = @existing_loc.tags.create(:tag => t);

            @roots.each {|r|
              if(t.index(r.word) != nil)
                @tag.suspect = true;
                @notify_admin_of_suspect = true;
                break;
              end
            }

            @tag.save
          else
            if(!@existing_tag.abusive)
              # Are the location and tag already linked?
              @ref = Reference.find(:first, :conditions => ["location_id=? and tag_id=? and time_block=?", @existing_loc.id, @existing_tag.id, @current_time_block]);
              if(@ref.nil?)
                # Link the location and tag together
                @existing_loc.tags.push(@existing_tag);
              else
                # Update the reference count for this location-tag pair
                @ref.count = @ref.count + 1;
                @ref.save
              end
            end
          end
        }

        # Save location
        if @existing_loc.save
          @status = "Success.";

          # Tie the user to the references
          logger.debug "user_valid"
          logger.debug @user_valid
          if(@user_valid)
            @rg_tag.each {|t|
              @tag = Tag.find(:first, :conditions => ["tag=?", t]);
              if(!@tag.nil?)
                @ref = Reference.find(:first, :conditions => ["location_id=? and tag_id=? and time_block=?", @existing_loc.id, @tag.id, @current_time_block]);
                if(!@ref.nil?)
                  @user_ref = UserReference.create(:user_id => @user.id, :reference_id => @ref.id);
                  @user_ref.save
                end
              end
            }
          end
        else
          @status = "Failure.";
        end
      else
        # Create new location
        @loc = Location.create(:lat => @lat, :lon => @lon);

        # If there are any new tags, add them to the database
        @rg_tag.each {|t|
          # Is this tag already in the database?
          @existing_tag = Tag.find(:first, :conditions => ["tag=?", t]);
          logger.debug "nil?"
          logger.debug @existing.nil?
          if(@exising_tag.nil?)
            # New tag, add to database
            @tag = @loc.tags.create(:tag => t);

            @roots.each {|r|
              if(t.index(r.word) != nil)
                @tag.suspect = true;
                @notify_admin_of_suspect = true;
                break;
              end
            }

            @tag.save
          end
        }

        # Save location
        if @loc.save
          @status = "Success.";

          # Tie the user to the references
          logger.debug "user_valid"
          logger.debug @user_valid
          if(@user_valid)
            @rg_tag.each {|t|
              @tag = Tag.find(:first, :conditions => ["tag=?", t]);
              if(!@tag.nil?)
                if(!@tag.abusive)
                  @ref = Reference.find(:first, :conditions => ["location_id=? and tag_id=? and time_block=?", @loc.id, @tag.id, @current_time_block]);
                  if(!@ref.nil?)
                    @user_ref = UserReference.create(:user_id => @user.id, :reference_id => @ref.id);
                    @user_ref.save
                  end
                end
              end
            }
          end
        else
          @status = "Failure.";
        end
      end
    else
      @status = "Failure. Tags Required.";
    end
  end

  #
  # show_range
  #
  def show_range
    @result = Tag.get_range(params[:lat1].to_f.round(3), params[:lon1].to_f.round(3), params[:lat2].to_f.round(3), params[:lon2].to_f.round(3),params[:tags])
  end

  #
  # show
  #
  def show
    @current_time_block = Reference.time_to_time_block(Time.now);
    @oldest_time_block = Reference.decrement_time_block(@current_time_block, 12); # 2 hours back

    # Convert lat/lon to float and round to 1/1000
    @lat = params[:lat].to_f.round(3);
    @lon = params[:lon].to_f.round(3);

    # Is this an existing location in the database?
    @existing_loc = Location.find(:first, :conditions => ["lat = ? and lon = ?", @lat, @lon]);
    if(!@existing_loc.nil?)
      # This is an existing location, parse tags
      @cst = params[:tags];
      if(!@cst.nil? && @cst.length > 0)
        # Create the result array
        @result = Array.new;

        # Convert all tags to lowercase
        @cst = @cst.downcase;

        # Parse comma separated list of tags
        @rg_tag = @cst.split(',');

        # Look for each tag in the database for this location
        @rg_tag.each {|t|
          # Find all tags for which this string is a substring
          @existing_tag = Tag.find(:all, :conditions => ["tag LIKE ?", "%"+t+"%"]);
          if(!@existing_tag.empty?)
            # We found at least 1 tag that matches
            @existing_tag.each {|e|
              if(!e.suspect && !e.abusive)
                # Is this tag tied to the current location?
                @ref = Reference.find(:first, :conditions => ["location_id=? and tag_id=? and time_block>=?", @existing_loc.id, e.id,@oldest_time_block]);
                if(!@ref.nil?)
                  # Add to results list
                  @res = Result.new;
                  @res.lat = @existing_loc.lat;
                  @res.lon = @existing_loc.lon;
                  @res.count = @ref.count;
                  @res.tag = e.tag;
                  @result.push(@res);
                end
              end
            }
          end
        }
      else
        # Create the result array
        @result = Array.new;

        # Create a result for each tag
        @tags = @existing_loc.tags;
        @tags.each {|t|
          if(!t.suspect && !t.abusive)
            @ref = Reference.find(:first, :conditions => ["location_id=? and tag_id=? and time_block>=?", @existing_loc.id, t.id, @oldest_time_block]);
            if(!@ref.nil?)
              @res = Result.new;
              @res.lat = @existing_loc.lat;
              @res.lon = @existing_loc.lon;
              @res.count = @ref.count;
              @res.tag = t.tag;
              @result.push(@res);
            end
          end
        }
      end
    else
      @result = nil;
    end
  end
end
