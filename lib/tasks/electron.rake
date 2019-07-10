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
    mnemonic = ENV.fetch('SECRET_MNEMONIC') { 'cry segment blue hello bid rain sheriff educate couple random office heavy credit borrow sugar shrimp cousin creek boil heavy edit credit shaft arrow couple right boat idea fashion rack screen equip grace crack army gather green radar occur change debris canvas flip silent chaos rack talk holiday give climb success give drip cost lumber almost cry situate assist second credit box sheriff proud cube book sudden gather globe october thunder erosion cry reason off skull casino radar office chase coral loan mirror security chaos broken sugar charge cushion canyon assist general crime grape three cry' }

    vault = Eth::Vault.new(secret_seed_phrase: mnemonic)
    index = args.with_defaults(index: '0')[:index].to_i

    puts "Address for #{index}: #{vault.get_key(index).address}"
  end
end
