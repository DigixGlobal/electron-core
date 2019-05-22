# frozen_string_literal: true

class DeviseTokenAuthCreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table(:users, id: false, force: true) do |t|
      t.string :id, limit: 36, primary_key: true, null: false
      t.string :provider, null: false, default: 'email'
      t.string :uid, null: false, default: ''

      t.string :encrypted_password, null: false, default: ''

      t.string   :reset_password_token
      t.datetime :reset_password_sent_at
      t.boolean  :allow_password_change, default: false

      t.datetime :remember_created_at

      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      t.string   :unlock_token # Only if unlock strategy is :email or :both
      t.datetime :locked_at

      t.string :email, limit: 254

      ## Tokens
      t.text :tokens

      t.timestamp :created_at
      t.timestamp :updated_at
    end

    add_index :users, :email, unique: true
    add_index :users, %i[uid provider], unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :confirmation_token,   unique: true
    # add_index :users, :unlock_token,       unique: true
  end
end
