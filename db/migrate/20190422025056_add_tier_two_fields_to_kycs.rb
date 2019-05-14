# frozen_string_literal: true

class AddTierTwoFieldsToKycs < ActiveRecord::Migration[5.2]
  def change
    change_table :kycs do |t|
      t.integer :applying_status, null: true, default: 0
      t.string :rejection_reason, limit: 150, null: true
      t.string :approval_txhash, limit: 80, null: true

      t.string :residence_line_1, limit: 1000, null: true
      t.string :residence_line_2, limit: 1000, null: true
      t.string :residence_city, limit: 250, null: true
      t.string :residence_postal_code, limit: 25, null: true
      t.integer :residence_proof_type, null: true
      t.integer :identification_proof_type, null: true
      t.date :identification_proof_expiration_date, null: true
      t.string :identification_proof_number, limit: 50, null: true

      t.text :residence_proof_image_data
      t.text :identification_proof_image_data
      t.text :identification_pose_image_data
    end

    add_index :kycs, :applying_status
  end
end
