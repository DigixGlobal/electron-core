# frozen_string_literal: true

puts 'Deleting old data'
User.delete_all

puts 'Seeding sample user'
puts 'Created user testuser01@support.com with password electron'
FactoryBot.create(:user_with_kyc, email: 'testuser01@support.com', password: 'electron')

puts 'Seeding sample KYC officer user'
puts 'Created user kycofficer@support.com with password electron'
FactoryBot.create(:kyc_officer_user, email: 'kycofficer@support.com', password: 'electron')
