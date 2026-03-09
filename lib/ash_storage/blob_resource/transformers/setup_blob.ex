defmodule AshStorage.BlobResource.Transformers.SetupBlob do
  @moduledoc false
  use Spark.Dsl.Transformer

  @before_transformers [
    Ash.Resource.Transformers.DefaultAccept,
    Ash.Resource.Transformers.SetTypes
  ]

  def before?(transformer) when transformer in @before_transformers, do: true

  def before?(AshOban.Transformers.SetDefaults), do: true
  def before?(AshOban.Transformers.DefineSchedulers), do: true
  def before?(AshOban.Transformers.DefineActionWorkers), do: true
  def before?(_), do: false

  def transform(dsl_state) do
    dsl_state
    |> add_attributes()
    |> add_calculations()
    |> add_actions()
  end

  defp add_attributes(dsl_state) do
    attrs = [
      {:key, :string, allow_nil?: false, public?: true, writable?: true},
      {:filename, :string, allow_nil?: false, public?: true, writable?: true},
      {:content_type, :string, allow_nil?: true, public?: true, writable?: true},
      {:byte_size, :integer, allow_nil?: true, public?: true, writable?: true},
      {:checksum, :string, allow_nil?: true, public?: true, writable?: true},
      {:service_name, :atom, allow_nil?: false, public?: true, writable?: true},
      {:service_opts, :map, allow_nil?: true, public?: true, writable?: true, default: %{}},
      {:metadata, :map, allow_nil?: true, public?: true, writable?: true, default: %{}},
      {:pending_purge, :boolean,
       allow_nil?: false, public?: true, writable?: true, default: false}
    ]

    Enum.reduce(attrs, {:ok, dsl_state}, fn {name, type, opts}, {:ok, dsl_state} ->
      Ash.Resource.Builder.add_new_attribute(dsl_state, name, type, opts)
    end)
  end

  defp add_calculations({:ok, dsl_state}) do
    Ash.Resource.Builder.add_calculation(
      dsl_state,
      :parsed_service_opts,
      :term,
      AshStorage.BlobResource.Calculations.ParsedServiceOpts,
      public?: false,
      filterable?: false,
      sortable?: false
    )
  end

  defp add_calculations({:error, error}), do: {:error, error}

  defp add_actions({:ok, dsl_state}) do
    with {:ok, dsl_state} <-
           Ash.Resource.Builder.add_action(dsl_state, :create, :create,
             primary?: true,
             accept: [
               :key,
               :filename,
               :content_type,
               :byte_size,
               :checksum,
               :service_name,
               :service_opts,
               :metadata
             ]
           ),
         {:ok, pagination} <-
           Ash.Resource.Builder.build_pagination(keyset?: true),
         {:ok, dsl_state} <-
           Ash.Resource.Builder.add_action(dsl_state, :read, :read,
             primary?: true,
             pagination: pagination
           ),
         {:ok, dsl_state} <-
           Ash.Resource.Builder.add_action(dsl_state, :destroy, :destroy, primary?: true),
         {:ok, dsl_state} <-
           Ash.Resource.Builder.add_action(dsl_state, :update, :update_metadata,
             accept: [:metadata]
           ),
         {:ok, dsl_state} <-
           Ash.Resource.Builder.add_action(dsl_state, :update, :mark_for_purge,
             accept: [:pending_purge]
           ) do
      {:ok, purge_change} =
        Ash.Resource.Builder.build_action_change(AshStorage.BlobResource.Changes.PurgeFile)

      Ash.Resource.Builder.add_action(dsl_state, :destroy, :purge_blob, changes: [purge_change])
    end
  end

  defp add_actions({:error, error}), do: {:error, error}
end
