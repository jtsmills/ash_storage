defmodule Demo.Page do
  @moduledoc false
  use Ash.Resource,
    domain: Demo.Domain,
    data_layer: Ash.DataLayer.Ets,
    extensions: [AshStorage.Resource]

  ets do
    private? false
  end

  storage do
    service(
      {AshStorage.Service.Disk,
       root: "tmp/dev_storage",
       base_url: "/disk_files",
       secret: "dev-secret-key-for-signed-urls!!"}
    )

    blob_resource(Demo.Blob)
    attachment_resource(Demo.Attachment)

    has_one_attached :cover_image
    has_many_attached :documents
  end

  attributes do
    uuid_primary_key :id
    attribute :title, :string, allow_nil?: false, public?: true
  end

  actions do
    defaults [:read, :destroy, create: [:title], update: [:title]]
  end
end
