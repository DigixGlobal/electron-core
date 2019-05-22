# frozen_string_literal: true

class CreateTestImages < ActiveRecord::Migration[5.2]
  def change
    create_table :test_images do |t|
      t.text :image_data
    end
  end
end
