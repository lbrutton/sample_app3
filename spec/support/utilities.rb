include ApplicationHelper

def sign_in(user, options={})
	if options[:no_capybara]
		#Sign in when not using Capybara - pass this option to override default sign in and manipulate cookies directly
		remember_token = User.new_remember_token
		cookies[:remember_token] = remember_token
		user.update_attribute(:remember_token, User.digest(remember_token))
	else
		visit signin_path
		fill_in "Email", with: user.email
		fill_in "Password", with: user.password
		click_button "Sign in"
	end
end
