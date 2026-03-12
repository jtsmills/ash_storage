defmodule AshStorage.AnalyzerDefinition do
  @moduledoc "Represents a configured analyzer on an attachment"
  defstruct [
    :module,
    :opts,
    :analyze,
    :write_attributes,
    :__spark_metadata__
  ]

  @schema [
    module: [
      type: {:or, [:atom, {:tuple, [:atom, :keyword_list]}]},
      doc:
        "The analyzer module (implementing `AshStorage.Analyzer`), or a `{module, opts}` tuple where opts are passed to `analyze/2`.",
      required: true
    ],
    analyze: [
      type: {:one_of, [:eager, :oban]},
      doc:
        "When to run this analyzer. `:eager` runs synchronously during attach, `:oban` runs in the background via AshOban.",
      default: :eager
    ],
    write_attributes: [
      type: :keyword_list,
      doc:
        "A keyword list mapping analyzer result keys to resource attributes. When the analyzer completes, result values matching these keys will be written to the corresponding attributes on the parent record.",
      default: []
    ]
  ]

  def schema, do: @schema

  @doc """
  Normalize an AnalyzerDefinition into a `{module, analyze_mode, opts, write_attributes}` tuple.
  """
  def normalize(%__MODULE__{} = defn) do
    {mod, opts} =
      case defn.module do
        {module, opts} when is_atom(module) and is_list(opts) -> {module, opts}
        module when is_atom(module) -> {module, []}
      end

    {mod, defn.analyze, opts, defn.write_attributes || []}
  end
end
