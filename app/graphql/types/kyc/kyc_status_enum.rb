# frozen_string_literal: true

module Types
  module Kyc
    class KycStatusEnum < Types::Base::BaseEnum
      description 'KYC status'

      value 'DRAFTED', 'KYC is drafted and can be modified before submitting ',
            value: 'drafted'
      value 'PENDING', 'KYC is pending and waiting for review from a KYC officer',
            value: 'pending'
      value 'APPROVING', 'KYC is approved by an KYC officer but not yet cascaded in the system',
            value: 'approving'
      value 'APPROVED', 'KYC is approved',
            value: 'approved'
      value 'REJECTED', 'KYC is rejected and user shoudl resubmit again',
            value: 'rejected'
    end
  end
end
