# frozen_string_literal: true

class AddEthAddressFieldsToUsers < ActiveRecord::Migration[5.2]
  def change
    change_table :users do |t|
      t.string :eth_address, null: true, limit: 42
      t.integer :change_eth_address_status, null: true
      t.string :new_eth_address, null: true, limit: 42
    end

    add_index :users, :eth_address, unique: true
    add_index :users, :new_eth_address, unique: true
  end
end
