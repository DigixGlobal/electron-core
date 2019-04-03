# frozen_string_literal: true

module SchemaHelpers
  def execute(query, variables, context = {})
    ElectronCoreSchema.execute(
      query,
      context: context,
      variables: variables
    )
  end
end
