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

	def current_user?(user)
		user == current_user
	end

	def signed_in_user
    unless signed_in?
    store_location
    redirect_to signin_path, notice: "Please sign in" #signin_url also works
    end
    #uses a shortcut to set flash:[notice] by passing an options hash to the redirect_to function. 
    #this is equivalent to: unless signed_in?
    #flash[:notice] = "Please sign in."
    #redirect_to signin_url
    #note: this was moved out of private methods in the users controller, so it would be available in the microposts controller, go figure
  	end

	def redirect_back_or(default)
		redirect_to(session[:return_to] || default)
		session.delete(:return_to)
	end

	def store_location
		session[:return_to] = request.url if request.get? #session facilty provided by rails, kind of like an instance of cookies that expires 
		#automatically upon browser close. We're also using the request object to get the url of the requested page. 
		#we check for get request to deal with certain edge cases, where the user might delete the cookies by hand before submitting a form
		#we don't want to store the forwarding url in that case...
	end
end
