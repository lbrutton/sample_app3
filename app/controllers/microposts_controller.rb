class MicropostsController < ApplicationController
	before_action :signed_in_user
	before_action :correct_user, only: :destroy

	def create
		@micropost = current_user.microposts.build(micropost_params)
		if @micropost.save
			flash[:success] = "Micropost created!"
			redirect_to root_url
		else
			@feed_items = [] #supress feed_items so that submitting invalid post doesn't fuck everything up
			render 'static_pages/home'
		end
	end

	def destroy
		@micropost.destroy
		redirect_to root_url
	end

	private

	def micropost_params
		params.require(:micropost).permit(:content)
	end

	def correct_user
		@micropost = current_user.microposts.find_by(id: params[:id]) #using find_by here, because find raises an exception
		redirect_to root_url if @micropost.nil?
	end

end