defmodule AshStorage do
  @moduledoc """
  An Ash extension for file storage and attachments.

  AshStorage provides a consistent interface for uploading, storing, and managing
  file attachments on Ash resources. It supports multiple storage backends
  (local disk, S3) and per-environment configuration.

  ## Getting started

  1. Create a blob resource with `AshStorage.BlobResource`
  2. Create an attachment resource with `AshStorage.AttachmentResource`
  3. Add `AshStorage.Resource` to your host resource and declare attachments

  See the [README](readme.html) for a full setup guide.

  ## Core modules

  - `AshStorage.Resource` — DSL extension for host resources
  - `AshStorage.BlobResource` — DSL extension for blob metadata resources
  - `AshStorage.AttachmentResource` — DSL extension for attachment join resources
  - `AshStorage.Operations` — Functions for attaching, detaching, and purging files
  - `AshStorage.Service` — Behaviour for storage backends
  """

  @doc """
  Generate a unique key for storing a file.

  Returns a 56-character lowercase hex string.
  """
  def generate_key do
    Base.encode16(:crypto.strong_rand_bytes(28), case: :lower)
  end
end
