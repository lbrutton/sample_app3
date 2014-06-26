class User < ActiveRecord::Base
    has_many :microposts, {:dependent => :destroy} #has_many here takes a symbol, plus a hash where :dependent is the key and :destroy is the value of that
    #key
	has_secure_password
	before_save { email.downcase! }
	before_create :create_remember_token
	validates :name, presence: true, length:{maximum: 50}
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(?:\.[a-z\d\-]+)*\.[a-z]+\z/i
    validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
    validates :password, length:{ minimum: 6 }

    def User.new_remember_token #these two methods are private because we need to access them outside of this model
    	SecureRandom.urlsafe_base64
    end

    def feed
        Micropost.where("user_id = ?", id)
    end

    def User.digest(token)
    	Digest::SHA1.hexdigest(token.to_s)
    end

    private 
    def create_remember_token
    	self.remember_token = User.digest(User.new_remember_token)
	end
end
