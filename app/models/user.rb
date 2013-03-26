class User < ActiveRecord::Base
  has_many :user_references, :dependent => :destroy
  has_many :references, :through => :user_references
end
