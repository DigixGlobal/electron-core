# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ElectronCoreSchema do
  describe 'app/graphql/schema.graphql' do
    it 'is updated' do
      current_schema = ElectronCoreSchema.to_definition
      generated_schema = File.read(Rails.root.join('app/graphql/schema.graphql'))

      expect(generated_schema).to(
        eq(current_schema),
        'Schema is not updated. Update it with `bundle exec rake electron:dump_schema`'
      )
    end
  end
end
