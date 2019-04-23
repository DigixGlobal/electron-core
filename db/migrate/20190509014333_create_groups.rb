# frozen_string_literal: true

class CreateGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :groups, id: false, force: true do |t|
      t.string :id, limit: 36, primary_key: true, null: false
      t.string :name, null: false

      t.index ['name'], name: 'index_groups_on_name', unique: true

      t.timestamp :created_at
      t.timestamp :updated_at
    end
  end
end
