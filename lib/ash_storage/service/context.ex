defmodule AshStorage.Service.Context do
  @moduledoc """
  Context passed to all service callbacks.

  Contains the service-specific options along with broader context about the
  resource, attachment, actor, and tenant. This allows services to make
  decisions based on who is performing the operation and what resource/attachment
  it applies to.

  ## Fields

  - `:service_opts` - keyword options from the `{ServiceModule, opts}` tuple
  - `:resource` - the host resource module (e.g. `MyApp.Post`), or `nil`
  - `:attachment` - the `%AttachmentDefinition{}` struct, or `nil`
  - `:actor` - the current actor, or `nil`
  - `:tenant` - the current tenant, or `nil`
  """
  defstruct [
    :resource,
    :attachment,
    :actor,
    :tenant,
    service_opts: []
  ]

  @type t :: %__MODULE__{
          resource: module() | nil,
          attachment: struct() | nil,
          actor: term(),
          tenant: term(),
          service_opts: keyword()
        }

  @doc """
  Build a context from service opts and optional extras.
  """
  def new(service_opts, extras \\ []) when is_list(service_opts) do
    %__MODULE__{
      service_opts: service_opts,
      resource: Keyword.get(extras, :resource),
      attachment: Keyword.get(extras, :attachment),
      actor: Keyword.get(extras, :actor),
      tenant: Keyword.get(extras, :tenant)
    }
  end
end
