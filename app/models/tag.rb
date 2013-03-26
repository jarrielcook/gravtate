class Tag < ActiveRecord::Base
  has_many :references, :dependent => :destroy
  has_many :locations, :through => :references

  def self.get_range(lat1, lon1, lat2, lon2, cst)
    @current_time_block = Reference.time_to_time_block(Time.now);
    @oldest_time_block = Reference.decrement_time_block(@current_time_block, 2*6); # 2 hours back

    # Is this an existing location in the database?
    @existing_locs = Location.find(:all, :conditions => ["lat >= ? and lat <= ? and lon >= ? and lon <= ?", lat1, lat2, lon1, lon2]);
    logger.debug "existing_locs"
    logger.debug @existing_locs.length
    if(@existing_locs.length > 0)
      # Create the result array
      @result = Array.new;

      @existing_locs.each {|l|
        # This is an existing location, parse tags
        if(!cst.nil? && cst.length > 0)
          # Convert all tags to lowercase
          cst = cst.downcase;

          # Parse comma separated list of tags
          @rg_tag = cst.split(',');

          # Look for each tag in the database for this location
          @rg_tag.each {|t|
            # Find all tags for which this string is a substring
            @existing_tag = Tag.find(:all, :conditions => ["tag LIKE ?", "%"+t+"%"]);
            if(!@existing_tag.empty?)
              # We found at least 1 tag that matches
              @existing_tag.each {|e|
                # Don't show if the tag is suspect or abusive
                if(!e.suspect && !e.abusive)
                  # Is this tag tied to the current location?
                  @ref = Reference.find(:first, :conditions => ["location_id=? and tag_id=? and time_block>=?", l.id, e.id, @oldest_time_block]);
                  if(!@ref.nil?)
                    # Add to results list
                    @res = Result.new;
                    @res.lat = l.lat;
                    @res.lon = l.lon;
                    @res.count = @ref.count;
                    @res.tag = e.tag;
                    @result.push(@res);
                  end
                end
              }
            end
          }
        else
          # Create a result for each tag
          @tags = l.tags;
          @tags.each {|t|
            if(!t.suspect && !t.abusive)
              @ref = Reference.find(:first, :conditions => ["location_id=? and tag_id=? and time_block>=?", l.id, t.id, @oldest_time_block]);
              if(!@ref.nil?)
                @res = Result.new;
                @res.lat = l.lat;
                @res.lon = l.lon;
                @res.count = @ref.count;
                @res.tag = t.tag;
                @result.push(@res);
              end
            end
          }
        end
      }
    else
      @result = nil;
    end

    @result;
  end
end
