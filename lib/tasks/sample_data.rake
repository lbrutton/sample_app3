namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    User.create!(name: "Example User",
                 email: "example@railstutorial.org",
                 password: "foobar",
                 password_confirmation: "foobar",
                 admin: true)
    99.times do |n|
      name  = Faker::Name.name
      email = "example#{n+1}@motherfucker.org"
      password  = "password"
      User.create!(name: name, #create! is the same as create, but it raises an exception instead of just returing false for an invalid user
                   email: email,
                   password: password,
                   password_confirmation: password)
    end
    users = User.all(limit: 6)
    50.times do 
      content = Faker::Lorem.sentence(5)
      users.each { |user| user.microposts.create!(content: content) }
    end
  end
end