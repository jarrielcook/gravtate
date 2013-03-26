class Location < ActiveRecord::Base
  has_many :references, :dependent => :destroy
  has_many :tags, :through => :references
end
