# frozen_string_literal: true

class ParamsForStrategy
  def initialize
    @strategy = FactoryBot.strategy_by_name(:attributes_for).new
  end

  delegate :association, to: :@strategy

  def association(runner)
    runner.run(:null)
  end

  def result(evaluation)
    res = @strategy.result(evaluation)

    res.deep_transform_keys! { |key| key.to_s.camelize(:lower) }
  end
end
