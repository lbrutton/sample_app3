require 'spec_helper'

describe User do
	before do
		@user = User.create(name: "Example User", email: "user@example.com", password: "foobar", password_confirmation: "foobar")
	end
	subject { @user }

	it { should respond_to(:name) }
	it { should respond_to(:email) }
	it { should respond_to(:password_digest)}
	it { should respond_to(:password)}
	it { should respond_to(:password_confirmation)}
	it { should respond_to(:authenticate)}
	it { should respond_to(:remember_token)}
	it { should respond_to(:microposts)}
	it { should respond_to(:admin)}
	it { should respond_to(:feed) }

	it { should be_valid }
	it { should_not be_admin } #this line implies that the user should have an admin? boolean method - which rails will give it automatically, 
	#because the attribute is already a boolean.

	describe "with admin set to 'true'" do
		before do
			@user.save!
			@user.toggle!(:admin) #flips the admin attribute from false to true
		end
		it { should be_admin}
	end

	describe "when name is not present" do
		before { @user.name = "" }

		it { should_not be_valid }
	end

	describe "when email is not present" do
		before { @user.email = "" }

		it { should_not be_valid }
	end

	describe "when name is too long" do
		before { @user.name = "a" * 51 }

		it { should_not be_valid }
	end

	/describe "when email address is already taken" do
	    before do
	      user_with_same_email = @user.dup
	      user_with_same_email.email = @user.email.upcase
	      user_with_same_email.save
	    end
		it { should_not be_valid }
  	end/



	describe "when email format is invalid" do
		it "should be invalid" do
			addresses = %w[user@foo,com user_at_foo.org example@foo. foo@bar_baz.com foo@bar+baz.com foo@bar..com]
			addresses.each do |invalid_email|
				@user.email = invalid_email
				expect(@user).not_to be_valid
			end
		end
	end

	describe "when email format is valid" do
		it "should be valid" do
			addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
			addresses.each do |valid_email|
				@user.email = valid_email
				expect(@user).to be_valid
			end
		end
	end

	describe "when password is not present" do
		before do
			@user = User.new(name: "Example User", email: "user@example.com", password:"", password_confirmation:"")
		end

		it { should_not be_valid }
	end

  describe "with a password that's too short" do
    before { @user.password = @user.password_confirmation = "a" * 5 }
    it { should be_invalid }
  end

  describe "return value of authenticate method" do
    before { @user.save }
    let(:found_user) { User.find_by(email: @user.email) }

    describe "with valid password" do
      it { should eq found_user.authenticate(@user.password) }
    end

    describe "with invalid password" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }

      it { should_not eq user_for_invalid_password }
      specify { expect(user_for_invalid_password).to be_false }
    end
  end

  describe "remember token" do
  	before { @user.save }
  	its(:remember_token){ should_not be_blank }
  end

  describe "micropost associations" do
  	before { @user.save }
  	let!(:older_micropost) do #let bang is to ensure that the variable exists from the moment it is defined, for the time stamps or something...
  		FactoryGirl.create(:micropost, user:@user, created_at:1.day.ago)
  	end
  	let!(:new_micropost) do
  		FactoryGirl.create(:micropost, user:@user, created_at:1.hour.ago)
  	end
  	it "should have the right microposts in the right order" do
  		expect(@user.microposts.to_a).to eq [new_micropost, older_micropost] #to_a converts what is actually an Active Record "collection proxy" (argh)
  		#to an array we can compare with the second part of the equation.
  	end

  	it "should destroy microposts with the user" do
  		microposts = @user.microposts.to_a #we have to make it an array, or it would DEFINITELY be empty later on - not sure about this
  		@user.destroy #remove @user from the db
  		expect(microposts).not_to be_empty
  		microposts.each do |micropost|
  			expect(Micropost.where(id: micropost.id)).to be_empty #where is used here because it returns an empty object instead of raising 
  			#and exception
  		end
  	end

  	describe "status" do
  		let(:unfollowed_post) do
  			FactoryGirl.create(:micropost, user: FactoryGirl.create(:user))
  		end

  		its(:feed) { should include(new_micropost) }
  		its(:feed) { should include(older_micropost) }
  		its(:feed) { should_not include(unfollowed_post) }
  	end
  end
end
