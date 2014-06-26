require 'spec_helper'

describe "MicropostPages" do

	subject {page}

	let(:user){FactoryGirl.create(:user)}
	before { sign_in user }

	describe "micropost creation" do
		before {visit root_path}

		describe "with invalid info" do

			it "should not create a micropost" do
				expect{ click_button "Post" }.not_to change(Micropost, :count)
			end

			describe "error messages" do
				before { click_button "Post" }
				it {should have_content('error')}
			end
		end

		describe "with valid information" do

			before { fill_in 'Compose new micropost...', with: "Lorem Ipsum" }
			it "should create a micropost" do
				expect{click_button "Post" }.to change(Micropost, :count).by(1)
			end
		end
	end

	describe "micropost deletion" do
		before {FactoryGirl.create(:micropost, user: user)}

		describe "as the correct user" do
			before { visit root_path }
		
			it "should delete the micropost" do
				expect { click_link "delete" }.to change(Micropost, :count).by(-1)
			end
		end
	end
end
