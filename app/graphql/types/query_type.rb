# frozen_string_literal: true

module Types
  class QueryType < Types::Base::BaseObject
    field :app_user, Types::User::AppUserType,
          resolver: Resolvers::AppUserResolver,
          description: "Get the user's application status"
    field :tnc, Types::Tnc::TncType,
          resolver: Resolvers::TncResolver,
          description: 'Get the application TnC'
    field :validation, Types::ValidationType,
          null: false,
          description: 'Field validations for the application'
    def validation
      {}
    end

    field :current_user, Types::User::UserType,
          resolver: Resolvers::CurrentUserResolver,
          description: "Get the current user's information"

    field :countries,
          resolver: Resolvers::CountriesResolver,
          description: 'List of countries for KYC'
    field :rejection_reasons,
          resolver: Resolvers::RejectionReasonsResolver,
          description: 'List of rejection reasons for KYC rejection'
  end
end
