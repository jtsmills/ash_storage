defmodule AshStorage.Resource.Calculations.AttachmentUrl do
  @moduledoc false
  use Ash.Resource.Calculation

  @impl true
  def init(opts) do
    {:ok, opts}
  end

  @impl true
  def strict_loads?, do: false

  @impl true
  def load(_query, opts, _context) do
    [{opts[:attachment_name], :blob}]
  end

  @impl true
  def calculate(records, opts, _context) do
    attachment_name = opts[:attachment_name]
    resource = opts[:resource]
    {:ok, attachment_def} = AshStorage.Resource.Info.attachment(resource, attachment_name)

    {:ok, {service_mod, service_opts}} =
      AshStorage.Resource.Info.service_for_attachment(resource, attachment_def)

    {:ok,
     Enum.map(records, fn record ->
       case Map.get(record, attachment_name) do
         nil -> nil
         attachment -> service_mod.url(attachment.blob.key, service_opts)
       end
     end)}
  end
end
