defmodule Demo.Attachment do
  @moduledoc false
  use Ash.Resource,
    domain: Demo.Domain,
    data_layer: Ash.DataLayer.Ets,
    extensions: [AshStorage.AttachmentResource]

  ets do
    private? false
  end

  attachment do
    blob_resource Demo.Blob
    belongs_to_resource :post, Demo.Post
    belongs_to_resource :page, Demo.Page
  end

  attributes do
    uuid_primary_key :id
  end
end
