# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def generate_uuid
    self.id = SecureRandom.uuid
  end
end
