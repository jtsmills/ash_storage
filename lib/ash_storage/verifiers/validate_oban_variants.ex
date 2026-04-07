defmodule AshStorage.Verifiers.ValidateObanVariants do
  @moduledoc false
  use Spark.Dsl.Verifier

  def verify(dsl_state) do
    has_oban_variants? =
      (AshStorage.Info.has_one_attachments(dsl_state) ++
         AshStorage.Info.has_many_attachments(dsl_state))
      |> Enum.any?(fn attachment_def ->
        Enum.any?(attachment_def.variants || [], fn variant_def ->
          variant_def.generate == :oban
        end)
      end)

    if has_oban_variants? do
      blob_resource = AshStorage.Info.storage_blob_resource!(dsl_state)
      validate_blob_has_trigger(blob_resource)
    else
      :ok
    end
  end

  defp validate_blob_has_trigger(blob_resource) do
    if Code.ensure_loaded?(AshOban.Info) do
      case AshOban.Info.oban_triggers(blob_resource) do
        triggers when is_list(triggers) ->
          if Enum.any?(triggers, &(&1.action == :run_pending_variants)) do
            :ok
          else
            {:error,
             Spark.Error.DslError.exception(
               message: """
               One or more variants use `generate: :oban`, but the blob resource \
               `#{inspect(blob_resource)}` does not have an AshOban trigger targeting \
               the `:run_pending_variants` action.

               Add an oban trigger to your blob resource:

                   oban do
                     triggers do
                       trigger :run_pending_variants do
                         action :run_pending_variants
                         read_action :read
                         where expr(...)
                         scheduler_cron("* * * * *")
                       end
                     end
                   end
               """
             )}
          end

        _ ->
          {:error,
           Spark.Error.DslError.exception(
             message: """
             One or more variants use `generate: :oban`, but the blob resource \
             `#{inspect(blob_resource)}` does not use the `AshOban` extension.

             Add `AshOban` to your blob resource's extensions and configure a trigger \
             for the `:run_pending_variants` action.
             """
           )}
      end
    else
      {:error,
       Spark.Error.DslError.exception(
         message: """
         One or more variants use `generate: :oban`, but `ash_oban` is not available. \
         Add `{:ash_oban, "~> 0.7"}` to your dependencies.
         """
       )}
    end
  end
end
