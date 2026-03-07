defmodule AshStorage.Service do
  @moduledoc """
  Behaviour for storage service backends.

  A service provides a uniform interface for storing, retrieving, and managing files
  regardless of the underlying storage technology (local disk, S3, GCS, Azure, etc.).

  All callbacks receive an `%AshStorage.Service.Context{}` struct which contains
  the service-specific options as well as broader context (resource, attachment,
  actor, tenant).

  ## Implementing a Service

  To implement a custom storage service, define a module that adopts this behaviour:

      defmodule MyApp.Storage.CustomService do
        @behaviour AshStorage.Service

        @impl true
        def upload(key, data, context) do
          bucket = context.service_opts[:bucket]
          # Upload implementation
        end

        # ... implement all callbacks
      end
  """

  alias AshStorage.Service.Context

  @type key :: String.t()

  @doc """
  Upload a file to the storage service.
  """
  @callback upload(key(), iodata() | File.Stream.t(), Context.t()) ::
              :ok | {:error, term()}

  @doc """
  Download a file from the storage service.

  Returns the file contents as binary data.
  """
  @callback download(key(), Context.t()) ::
              {:ok, binary()} | {:error, term()}

  @doc """
  Delete a file from the storage service.
  """
  @callback delete(key(), Context.t()) :: :ok | {:error, term()}

  @doc """
  Check if a file exists in the storage service.
  """
  @callback exists?(key(), Context.t()) :: {:ok, boolean()} | {:error, term()}

  @doc """
  Generate a URL for accessing a file.

  Service-specific options like `:expires_in`, `:disposition`, `:filename`,
  and `:content_type` can be passed via the context's service_opts.
  """
  @callback url(key(), Context.t()) :: String.t()

  @doc """
  Upload multiple files to the storage service in bulk.

  Receives a list of `{key, data}` tuples. Services that support bulk/multipart
  uploads can override this for efficiency.
  """
  @callback upload_many([{key(), iodata() | File.Stream.t()}], Context.t()) ::
              :ok | {:error, term()}

  @doc """
  Delete multiple files from the storage service in bulk.

  Services that support bulk deletes can override this for efficiency.
  """
  @callback delete_many([key()], Context.t()) :: :ok | {:error, term()}

  @doc """
  Generate a presigned URL or form for direct client-side upload.

  Returns a map with at minimum a `:url` key. Depending on the service,
  it may also include `:headers` (for presigned PUT) or `:fields` (for
  presigned POST/form uploads).
  """
  @callback direct_upload(key(), Context.t()) ::
              {:ok, map()} | {:error, term()}

  @optional_callbacks upload_many: 2, delete_many: 2, direct_upload: 2
end
