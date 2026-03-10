defmodule Demo.Post do
  @moduledoc false
  use Ash.Resource,
    domain: Demo.Domain,
    data_layer: Ash.DataLayer.Ets,
    extensions: [AshStorage]

  ets do
    private? false
  end

  storage do
    service(
      {AshStorage.Service.S3,
       bucket: "ash-storage-dev",
       region: "us-east-1",
       access_key_id: "minioadmin",
       secret_access_key: "minioadmin",
       endpoint_url: "http://localhost:19000",
       presigned: true}
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
