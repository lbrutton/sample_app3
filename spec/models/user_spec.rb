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
	it { should respond_to(:admin)}

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
end
