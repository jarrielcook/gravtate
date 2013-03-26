require 'digest/sha1'

class Administrator < ActiveRecord::Base
    validates_presence_of   :fullname
    validates_presence_of   :username
    validates_uniqueness_of :username
    validates_presence_of   :password
    validates_length_of     :password, :minimum =>6
    validates_presence_of   :email
    validates_format_of     :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create

    before_create :hash_password

    def self.authenticate(username,password)
        password = Digest::SHA1.hexdigest(password)
        find(:first, :conditions => ["username = ? AND password = ?", username, password])
    end

    def hash_password
        self.password = Digest::SHA1.hexdigest(self.password)
    end
end
