defmodule AshStorage.VariantDefinition do
  @moduledoc "Represents a configured variant on an attachment"
  defstruct [
    :name,
    :module,
    :generate,
    :__spark_metadata__
  ]

  @schema [
    name: [
      type: :atom,
      doc: "Unique name for this variant (e.g. `:thumbnail`, `:hero`).",
      required: true
    ],
    module: [
      type: {:or, [:atom, {:tuple, [:atom, :keyword_list]}]},
      doc:
        "The variant module (implementing `AshStorage.Variant`), or a `{module, opts}` tuple where opts are passed to `transform/3`.",
      required: true
    ],
    generate: [
      type: {:one_of, [:on_demand, :eager, :oban]},
      doc:
        "When to generate this variant. `:on_demand` generates on first URL request, `:eager` during attach, `:oban` via background job.",
      default: :on_demand
    ]
  ]

  def schema, do: @schema

  @doc """
  Normalize a VariantDefinition into a `{module, opts}` tuple.
  """
  def normalize(%__MODULE__{} = defn) do
    case defn.module do
      {module, opts} when is_atom(module) and is_list(opts) -> {module, opts}
      module when is_atom(module) -> {module, []}
    end
  end

  @doc """
  Compute a digest of the variant definition for cache invalidation.
  """
  def digest(%__MODULE__{} = defn) do
    {mod, opts} = normalize(defn)

    :crypto.hash(:sha256, :erlang.term_to_binary({mod, opts}))
    |> Base.encode16(case: :lower)
    |> binary_part(0, 16)
  end
end
