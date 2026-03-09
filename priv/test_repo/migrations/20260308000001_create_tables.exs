defmodule AshStorage.TestRepo.Migrations.CreateTables do
  use Ecto.Migration

  def up do
    create table(:storage_blobs, primary_key: false) do
      add :id, :uuid, null: false, primary_key: true
      add :key, :text, null: false
      add :filename, :text, null: false
      add :content_type, :text
      add :byte_size, :bigint
      add :checksum, :text
      add :service_name, :text, null: false
      add :service_opts, :map, default: %{}
      add :metadata, :map, default: %{}
      add :pending_purge, :boolean, null: false, default: false
    end

    create table(:posts, primary_key: false) do
      add :id, :uuid, null: false, primary_key: true
      add :title, :text, null: false
    end

    create table(:storage_attachments, primary_key: false) do
      add :id, :uuid, null: false, primary_key: true
      add :name, :text, null: false
      add :post_id, references(:posts, type: :uuid, on_delete: :nilify_all)
      add :blob_id, references(:storage_blobs, type: :uuid, on_delete: :nothing), null: false
    end
  end

  def down do
    drop table(:storage_attachments)
    drop table(:posts)
    drop table(:storage_blobs)
  end
end
