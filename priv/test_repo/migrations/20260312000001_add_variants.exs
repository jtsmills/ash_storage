defmodule AshStorage.TestRepo.Migrations.AddVariants do
  use Ecto.Migration

  def up do
    alter table(:storage_blobs) do
      add :variant_of_blob_id, references(:storage_blobs, type: :uuid, on_delete: :delete_all)
      add :variant_name, :string
      add :variant_digest, :string
    end

    create index(:storage_blobs, [:variant_of_blob_id, :variant_name, :variant_digest])
  end

  def down do
    drop index(:storage_blobs, [:variant_of_blob_id, :variant_name, :variant_digest])

    alter table(:storage_blobs) do
      remove :variant_of_blob_id
      remove :variant_name
      remove :variant_digest
    end
  end
end
