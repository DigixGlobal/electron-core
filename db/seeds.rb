# frozen_string_literal: true

puts 'Deleting old data'
User.delete_all

puts 'Seeding sample users'
puts 'Created user testuser01@support.com with password electron'
FactoryBot.create(:user_with_kyc, email: 'testuser01@support.com', password: 'electron')
