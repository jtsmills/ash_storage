defmodule Demo.Blob do
  @moduledoc false
  use Ash.Resource,
    domain: Demo.Domain,
    data_layer: Ash.DataLayer.Ets,
    extensions: [AshStorage.BlobResource]

  ets do
    private? false
  end

  blob do
  end

  attributes do
    uuid_primary_key :id
  end
end
