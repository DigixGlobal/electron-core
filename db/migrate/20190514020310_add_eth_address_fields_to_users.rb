# frozen_string_literal: true

class AddEthAddressFieldsToUsers < ActiveRecord::Migration[5.2]
  def change
    change_table :users do |t|
      t.string :eth_address, null: true, limit: 42
      t.string :new_eth_address, null: true, limit: 42
      t.string :change_eth_address_token, null: true
      t.datetime :change_eth_address_sent_at, null: true
    end

    add_index :users, :eth_address, unique: true
    add_index :users, :new_eth_address, unique: true
    add_index :users, :change_eth_address_token, unique: true
  end
end
