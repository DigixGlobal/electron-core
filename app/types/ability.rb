# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(entity)
    return unless (user = User.find(entity.id)) && user.confirmed?

    kyc = user.kyc

    if kyc &&
       (kyc.tier == :tier_1.to_s) &&
       (kyc.applying_status.nil? || [:drafted.to_s, :rejected.to_s].include?(kyc.applying_status))
      can :draft, KycTypes::Tier2KycEntity
    end

    can :change_eth_address, AccountTypes::UserEntity

    if kyc && (kyc.applying_status == :drafted.to_s) && !user.eth_address.blank?
      can :submit, KycTypes::KycEntity
    end

    user.groups.pluck(:name).each do |group_name|
      case Group.groups.invert[group_name]
      when 'kyc_officer'
        cannot :draft, KycTypes::Tier2KycEntity
        cannot :submit, KycTypes::KycEntity
        cannot :change_eth_address, AccountTypes::UserEntity

        can :read, KycTypes::KycEntity
        can :approve, KycTypes::Tier2KycEntity, status: 'pending'
        can :reject, KycTypes::Tier2KycEntity, status: 'pending'
      end
    end
  end
end
