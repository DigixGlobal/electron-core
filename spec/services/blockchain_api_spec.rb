# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BlockchainApi, type: :api do
  let(:api) { described_class }

  describe '.fetch_latest_block_number' do
    let(:block_number) { SecureRandom.random_number(1000..10_000).to_s }
    let(:block) { SecureRandom.hex }

    specify 'should work' do
      stub_request(:post, BlockchainApi::BLOCKCHAIN_URL)
        .with(body: /eth_blockNumber/)
        .to_return(body: { result: block_number.to_i.to_s(16) }.to_json)

      expect(api.fetch_latest_block_number).to(be_success)
    end

    it 'should fail safely when ethereum is down' do
      stub_request(:post, BlockchainApi::BLOCKCHAIN_URL)
        .to_raise(StandardError)

      expect(api.fetch_latest_block_number).to(be_failure)
    end
  end

  describe '.fetch_latest_block' do
    let(:block_number) { SecureRandom.random_number(1000..10_000).to_s }
    let(:block) { SecureRandom.hex }

    specify 'should work' do
      stub_request(:post, BlockchainApi::BLOCKCHAIN_URL)
        .with(body: /eth_blockNumber/)
        .to_return(body: { result: block_number.to_i.to_s(16) }.to_json)

      stub_request(:post, BlockchainApi::BLOCKCHAIN_URL)
        .with(body: /eth_getBlockByNumber/)
        .to_return(body: {
          result: { 'hash' => "0x#{block.slice(0, 2)}1234#{block.slice(-2, 2)}" }
        }.to_json)

      expect(api.fetch_latest_block).to(be_success)
    end

    it 'should fail when block number does not exist' do
      stub_request(:post, BlockchainApi::BLOCKCHAIN_URL)
        .with(body: /eth_blockNumber/)
        .to_return(body: { error: 'FOO' }.to_json)

      expect(api.fetch_latest_block).to(be_failure)
    end

    it 'should fail safely when ethereum is down' do
      stub_request(:post, BlockchainApi::BLOCKCHAIN_URL)
        .to_raise(StandardError)

      expect(api.fetch_latest_block).to(be_failure)
    end
  end

  describe '.fetch_block_by_block_number' do
    let(:block_number) { SecureRandom.random_number(1000..10_000).to_s }
    let(:block) { SecureRandom.hex }

    specify 'should work' do
      stub_request(:post, BlockchainApi::BLOCKCHAIN_URL)
        .with(body: /eth_getBlockByNumber/)
        .to_return(body: {
          result: {
            'number' => '0xb73',
            'hash' => "0x#{block.slice(0, 2)}1234#{block.slice(-2, 2)}",
            'parent_hash' => '0x1f3f29ffbb1547029f351a667ec181a0072cb6d7e51bd6d0e2bf26c9d319ab64',
            'mix_hash' => '0x0000000000000000000000000000000000000000000000000000000000000000',
            'nonce' => '0x0000000000000000',
            'sha3_uncles' => '0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347',
            'logs_bloom' => '0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000',
            'transactions_root' => '0xc3c7f4fc445496d7e83b60ae99670d5e2732ab2c47d33625a2ab74fc4c9debc8',
            'state_root' => '0xa1177a586850282d6cd09923a01c3dd47b9e57cadde3bb3cdc620be690b2f472',
            'receipts_root' => '0x056b23fbba480696b65fe5a59b8f2148a1299103c4f57df839233af2cf4ca2d2',
            'miner' => '0x0000000000000000000000000000000000000000',
            'difficulty' => '0x0',
            'total_difficulty' => '0x0',
            'extra_data' => '0x',
            'size' => '0x3e8',
            'gas_limit' => '0xfffffffffff',
            'gas_used' => '0x5208',
            'timestamp' => '0x5ccb7930',
            'transactions' => ['0x5dca574072e8cf937063d912c7483c8155f0abfce144d4c15df452bfcb0f8f0c'],
            'uncles' => []
          }
        }.to_json)

      result = api.fetch_block_by_block_number(block_number)

      expect(result).to(be_success)
      expect(result.value!).to(include('number', 'hash', 'parent_hash', 'mix_hash', 'nonce', 'sha3_uncles', 'logs_bloom', 'transactions_root', 'state_root', 'receipts_root', 'miner', 'difficulty', 'total_difficulty', 'extra_data', 'size', 'gas_limit', 'gas_used', 'timestamp', 'transactions', 'uncles'))
    end

    it 'should fail when block number does not exist' do
      stub_request(:post, BlockchainApi::BLOCKCHAIN_URL)
        .with(body: /eth_getBlockByNumber/)
        .to_return(body: { error: 'FOO' }.to_json)

      expect(api.fetch_block_by_block_number(block_number))
        .to(be_failure)
    end

    it 'should fail safely when ethereum is down' do
      stub_request(:post, BlockchainApi::BLOCKCHAIN_URL)
        .to_return(status: [404, 'Not Found'])

      expect(api.fetch_block_by_block_number(block_number))
        .to(be_failure)
    end
  end
end
