# frozen_string_literal: true

require 'cancancan'

module Mutations
  class DraftTier2KycMutation < Types::Base::BaseMutation
    description <<~EOS
      As the current user of KYC tier one, draft a tier 2 KYC to access more features of the app.
    EOS

    argument :identification_proof_number, String,
             required: true,
             description: <<~EOS
               Code/number of the ID.

               Validations:
               - Maximum of 50 characters
             EOS
    argument :identification_proof_type, Types::Kyc::KycIdentificationProofTypeEnum,
             required: true,
             description: 'Type of ID used'
    argument :identification_proof_expiration_date, Types::Scalar::Date,
             required: true,
             description: <<~EOS
               Expiration date of the ID.

               Validations:
               - Must not be expired or a future date
             EOS
    argument :identification_proof_image, Types::Scalar::DataUrl,
             required: true,
             description: <<~EOS
               Image data URL to prove personal identification.

               Validations:
               - Maximum of 10 MB size
               - JPEG, PNG or PDF files only
             EOS
    argument :residence_line_1, String,
             required: true,
             description: <<~EOS
               Descriptive combination of unit/block/house number and street name of the user.

               Validations:
               - Maximum of 1000 characters
             EOS
    argument :residence_line_2, String,
             required: false,
             description: <<~EOS
               Extra descriptions about the address such as landmarks or corners.

               Validations:
               - Maximum of 1000 characters
             EOS
    argument :residence_city, String,
             required: true,
             description: <<~EOS
               City address of the user.

               Validations:
               - Maximum of 250 characters
             EOS
    argument :residence_postal_code, String,
             required: true,
             description: <<~EOS
               Postal code address of the user.

               Validations:
               - Maximum of 12 characters
               - Must be comprised of alphanumeric characters (`A-Z0-9`), spaces and dashes (`-`)
               - Must not end or begin with a dash
             EOS
    argument :residence_proof_type, Types::Kyc::KycResidenceProofTypeEnum,
             required: true,
             description: 'Kind/type of proof presented for residence'
    argument :residence_proof_image, Types::Scalar::DataUrl,
             required: true,
             description: <<~EOS
               Image data URL to prove personal residence

               Validations:
               - Maximum of 10 MB size
               - JPEG, PNG or PDF files only
             EOS
    argument :identification_pose_image, Types::Scalar::DataUrl,
             required: true,
             description: <<~EOS
               Image data URL to prove identification is valid

               Validations:
               - Maximum of 10 MB size
               - JPEG or PNG files only
             EOS

    field :applying_kyc, Types::Kyc::KycTier2Type,
          null: true,
          description: 'Newly drafted KYC tier 2 application'
    field :errors, [UserErrorType],
          null: false,
          description: <<~EOS
            Mutation errors

            Operation Errors:
            - Not qualified for this tier
            - Already have a pending or active KYC
          EOS

    KEY = :applying_kyc

    def resolve(attrs)
      user = context.fetch(:current_user)

      attrs[:residence_line_1] ||= attrs.delete(:residence_line1)
      attrs[:residence_line_2] ||= attrs.delete(:residence_line2)

      result = KycService.draft_tier2_kyc(user.id, attrs)

      AppMatcher.result_matcher.call(result) do |m|
        m.success { |kyc| model_result(KEY, kyc) }
        m.failure(:invalid_data) { |errors| model_errors(KEY, errors) }
        m.failure(:unauthorized_action) { |_| form_error(KEY, 'Not qualified to draft a KYC') }
      end
    end

    def self.authorized?(object, context)
      super &&
        (user = context.fetch(:current_user, nil)) &&
        Ability.new(user).can?(:draft, KycTypes::Tier2KycEntity)
    end
  end
end
