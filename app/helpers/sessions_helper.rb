module SessionsHelper
	def sign_in(user)
	    remember_token = User.new_remember_token #simply creates a random 16 (?) char string
	    cookies.permanent[:remember_token] = remember_token #saves the raw, unhashed, token in the browser cookies
	    user.update_attribute(:remember_token, User.digest(remember_token)) #saves the hashed token to the database
	    self.current_user = user #sets current_user equal to the given user - without "self" ruby would just create a local variable current_user.
	    #this is automatically converted to current_user=(...), a method defined below. Note: this code is basically just Hartl being ridiculously exigeant
	    #and I think we could actually just use @user or something?
    end

    def current_user=(user)
    	@current_user = user #sets an instance variable @current_user, effectively storing the user for later use
    end

    def current_user
    	remember_token = User.digest(cookies[:remember_token]) #finds the current user's remember token
    	@current_user ||= User.find_by(remember_token: remember_token) #uses it to create current_user, but only if current user is not defined
    end

    def signed_in?
    	!current_user.nil?
    end

	def sign_out
		current_user.update_attribute(:remember_token, User.digest(User.new_remember_token)) #change current remember_token, in case it's been stolen
		cookies.delete(:remember_token) #delete the remeber token from the cookie (so how could anyone possibly access the site? above line is strange)
		self.current_user = nil #sets current_user to nil, nothing more to say
	end
end
