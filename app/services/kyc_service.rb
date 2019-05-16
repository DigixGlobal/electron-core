# frozen_string_literal: true

module KycService
  def self.find(id)
    return nil unless (kyc = Kyc.kept.find_by(id: id))

    KycTypes::KycEntity.from_model(kyc)
  end

  def self.find_by_user(user_id)
    return nil unless (kyc = Kyc.kept.find_by(user_id: user_id))

    KycTypes::KycEntity.from_model(kyc)
  end

  def self.find_applying(id)
    return nil unless (kyc = Kyc.kept.find_by(id: id))

    if kyc.tier == :tier_1.to_s && !kyc.applying_status.nil?
      return KycTypes::Tier2KycEntity.from_model(kyc)
    end

    if kyc.tier == :tier_2.to_s && [:approving.to_s, :approved.to_s].include?(kyc.applying_status)
      return KycTypes::Tier2KycEntity.from_model(kyc)
    end

    nil
  end

  def self.find_applying_by_user(user_id)
    return nil unless (kyc = Kyc.kept.find_by(user_id: user_id))

    find_applying(kyc.id)
  end

  def self.register_kyc(user_id, attrs)
    Kycs::RegisterKyc.new.call(user_id: user_id, attrs: attrs)
  end

  def self.draft_tier2_kyc(user_id, attrs)
    Kycs::DraftTier2Kyc.new.call(user_id: user_id, attrs: attrs)
  end

  def self.verify_code(code)
    Kycs::VerifyCode.new.call(code)
  end

  def self.submit_applying_user_kyc(user_id)
    Kycs::SubmitApplyingKyc.new.call(user_id)
  end

  def self.approve_applying_kyc(officer_id, applying_kyc_id, attrs)
    Kycs::ApproveApplyingKyc.new.call(
      officer_id: officer_id,
      applying_kyc_id: applying_kyc_id,
      attrs: attrs
    )
  end

  def self.reject_applying_kyc(officer_id, applying_kyc_id, attrs)
    Kycs::RejectApplyingKyc.new.call(
      officer_id: officer_id,
      applying_kyc_id: applying_kyc_id,
      attrs: attrs
    )
  end

  def self.mark_kyc_approved(attrs)
    Kycs::MarkKycApproved.new.call(attrs)
  end
end
