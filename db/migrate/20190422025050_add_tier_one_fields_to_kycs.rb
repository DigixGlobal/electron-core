# frozen_string_literal: true

class AddTierOneFieldsToKycs < ActiveRecord::Migration[5.2]
  def change
    change_table :users do |t|
      t.string :tnc_version, limit: 50, null: false
    end

    change_table :kycs do |t|
      t.string :first_name, limit: 255, null: true
      t.string :last_name, limit: 255, null: true
      t.string :residence_country, limit: 150, null: true
      t.string :citizenship, limit: 150, null: true
      t.date :birthdate, null: true
    end
  end
end
