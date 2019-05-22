# frozen_string_literal: true

class CreateKycs < ActiveRecord::Migration[5.2]
  def change
    create_table :kycs, id: false, force: true do |t|
      t.string :id, limit: 36, primary_key: true, null: false

      t.integer :tier, null: false, default: 1
      t.date :expiration_date, null: true
      t.datetime :discarded_at

      t.references :user, foreign_key: false, column: :user_id, name: :fk_rails_user_id, type: :string
      t.references :officer, foreign_key: false, column: :officer_id, name: :fk_rails_officer_id, type: :string

      t.timestamp :created_at
      t.timestamp :updated_at
    end

    add_index :kycs, :discarded_at
  end
end
