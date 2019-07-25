# frozen_string_literal: true

require 'cancancan'

module Mutations
  class DraftTier2KycMutation < Types::Base::BaseMutation
    description <<~EOS
      As the current user of KYC tier one, draft a tier 2 KYC to access more features of the app.
       With the submit field true, also submit the KYC.
    EOS

    argument :form_step, Types::Scalar::PositiveInteger,
             required: true,
             description: <<~EOS
               An integer indicating the current step of the wizard of process.

               Although it has no semantic meaning, this is the only required field
                to indicate progress.
             EOS
    argument :submit, Boolean,
             required: false,
             description: <<~EOS
               A flag to indicate to submit the draft after updating it.
                Usually, true when it is the final operation in a wizard.

               Before setting this true, all fields should be completed or
                this mutation will fail.
             EOS

    argument :identification_proof_number, String,
             required: false,
             description: <<~EOS
               Code/number of the ID.

               Validations:
               - Maximum of 50 characters
             EOS
    argument :identification_proof_type, Types::Kyc::KycIdentificationProofTypeEnum,
             required: false,
             description: 'Type of ID used'
    argument :identification_proof_expiration_date, Types::Scalar::Date,
             required: false,
             description: <<~EOS
               Expiration date of the ID.

               Validations:
               - Must not be expired or a future date
             EOS
    argument :identification_proof_image, Types::Scalar::DataUrl,
             required: false,
             description: <<~EOS
               Image data URL to prove personal identification.

               Validations:
               - Maximum of 10 MB size
               - JPEG, PNG or PDF files only
             EOS
    argument :residence_line_1, String,
             required: false,
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
             required: false,
             description: <<~EOS
               City address of the user.

               Validations:
               - Maximum of 250 characters
             EOS
    argument :residence_postal_code, String,
             required: false,
             description: <<~EOS
               Postal code address of the user.

               Validations:
               - Maximum of 12 characters
               - Must be comprised of alphanumeric characters (`A-Z0-9`), spaces and dashes (`-`)
               - Must not end or begin with a dash
             EOS
    argument :residence_proof_image, Types::Scalar::DataUrl,
             required: false,
             description: <<~EOS
               Image data URL to prove personal residence

               Validations:
               - Maximum of 10 MB size
               - JPEG, PNG or PDF files only
             EOS
    argument :identification_pose_image, Types::Scalar::DataUrl,
             required: false,
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

    def resolve(submit: false, **attrs)
      user = context.fetch(:current_user)

      attrs[:residence_line_1] ||= attrs.delete(:residence_line1) if attrs.key?(:residence_line1)
      attrs[:residence_line_2] ||= attrs.delete(:residence_line2) if attrs.key?(:residence_line2)

      result = KycService.draft_tier2_kyc(user.id, attrs)

      AppMatcher.result_matcher.call(result) do |m|
        m.success do |kyc|
          return model_result(KEY, kyc) unless submit

          result = KycService.submit_applying_user_kyc(user.id)

          AppMatcher.result_matcher.call(result) do |im|
            im.success { |submitted_kyc| model_result(KEY, submitted_kyc) }
            im.failure(:kyc_not_pending) { |errors| model_errors(KEY, errors) }
            im.failure(:invalid_data) { |errors| model_errors(KEY, errors) }
            im.failure { |_| form_error(KEY, 'Error in submitting KYC') }
          end
        end
        m.failure(:invalid_data) { |errors| model_errors(KEY, errors) }
        m.failure(:kyc_not_drafted) { |_| form_error(KEY, 'KYC already submitted or not drafted') }
        m.failure(:unauthorized_action) { |_| form_error(KEY, 'Not qualified to draft a KYC') }
        m.failure { |_| form_error(KEY, 'Error in drafting KYC') }
      end
    end

    def self.visible?(context)
      super && context.fetch(:current_user, nil)
    end

    def self.authorized?(object, context)
      super && context.fetch(:current_user, nil)
    end
  end
end
