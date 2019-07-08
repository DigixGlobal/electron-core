# frozen_string_literal: true

namespace :electron do
  desc 'Rake tasks for Electron Core'
  task dump_schema: :environment do
    schema_defn = ElectronCoreSchema.to_definition
    schema_path = 'app/graphql/schema.graphql'
    File.write(Rails.root.join(schema_path), schema_defn)

    puts "Updated #{schema_path}"
  end

  task :fetch_vault_key, [:index] do |_task, args|
    secret_mnemonic = ENV.fetch('PRICEFEED_SECRET_MNEMONIC') { '58da5aab1b4166f53046691fdd54ff18e178c855a0baef8006eaf118d5dd2ea7cfbeca142aa865947a3051ef5c3b06528be56beeb7afa500b6abd96146d870c8' }

    seed_phrase = Bitcoin::Trezor::Mnemonic.to_mnemonic(secret_mnemonic)
    vault = Eth::Vault.new(secret_seed_phrase: seed_phrase)
    index = args.with_defaults(index: '0')[:index].to_i

    puts "Address for #{index}: #{vault.get_key(index).address}"
  end
end
