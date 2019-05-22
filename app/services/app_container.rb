# frozen_string_literal: true

class AppContainer
  extend Dry::Container::Mixin

  M = Dry::Monads

  register 'transaction' do |input, &block|
    result = M.Failure

    ActiveRecord::Base.transaction do
      result = block.call(M.Success(input))

      raise ActiveRecord::Rollback if result.failure?
    end

    result
  rescue ActiveRecord::Rollback
    M.Failure
  end
end
