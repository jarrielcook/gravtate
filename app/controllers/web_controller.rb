class WebController < ApplicationController
  def index
  end

  def map
    @lat = params[:lat];
    @lon = params[:lon];
    @result = Tag.get_range(params[:lat1].to_f.round(3), params[:lon1].to_f.round(3), params[:lat2].to_f.round(3), params[:lon2].to_f.round(3), '')
  end
end
