# frozen_string_literal: true

namespace :electron do
  desc 'Rake tasks for Electron Core'
  task dump_schema: :environment do
    schema_defn = ElectronCoreSchema.to_definition
    schema_path = 'app/graphql/schema.graphql'
    File.write(Rails.root.join(schema_path), schema_defn)

    puts "Updated #{schema_path}"
  end
end
