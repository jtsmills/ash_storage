defmodule AshStorage.VariantObanTest do
  use AshStorage.RepoCase, async: false
  use Oban.Testing, repo: AshStorage.TestRepo

  @moduletag :oban

  alias AshStorage.Test.PgPost

  setup do
    AshStorage.Service.Test.reset!()
    :ok
  end

  defp create_post!(title \\ "test post") do
    PgPost
    |> Ash.Changeset.for_create(:create, %{title: title})
    |> Ash.create!()
  end

  describe "eager variant generation on Postgres" do
    test "generates eager variant blobs during attach" do
      post = create_post!()

      {:ok, %{blob: blob}} =
        AshStorage.Operations.attach(post, :cover_image, "hello world",
          filename: "test.txt",
          content_type: "text/plain"
        )

      # Load variants from the blob
      blob = Ash.load!(blob, :variants)

      # eager_upper should be generated
      eager = Enum.find(blob.variants, &(&1.variant_name == "eager_upper"))
      assert eager != nil
      assert eager.variant_of_blob_id == blob.id

      {:ok, data} = AshStorage.Service.Test.download(eager.key, [])
      assert data == "HELLO WORLD"
    end
  end

  describe "oban variant generation on Postgres" do
    test "stores pending variant info in blob metadata" do
      post = create_post!()

      {:ok, %{blob: blob}} =
        AshStorage.Operations.attach(post, :cover_image, "hello world",
          filename: "test.txt",
          content_type: "text/plain"
        )

      pending = blob.metadata["__pending_variants__"]
      assert pending != nil
      assert pending["oban_upper"]["status"] == "pending"
      assert pending["oban_upper"]["module"] == to_string(AshStorage.Test.UppercaseVariant)
    end

    test "pending_variants flag is set during attach" do
      post = create_post!()

      {:ok, %{blob: blob}} =
        AshStorage.Operations.attach(post, :cover_image, "hello world",
          filename: "test.txt",
          content_type: "text/plain"
        )

      assert blob.pending_variants == true
    end

    test "pending_variants flag clears after run_pending_variants" do
      post = create_post!()

      {:ok, %{blob: blob}} =
        AshStorage.Operations.attach(post, :cover_image, "hello world",
          filename: "test.txt",
          content_type: "text/plain"
        )

      assert blob.pending_variants == true

      {:ok, blob} = Ash.update(blob, %{}, action: :run_pending_variants)

      assert blob.pending_variants == false
    end

    test "run_pending_variants action generates variant blobs" do
      post = create_post!()

      {:ok, %{blob: blob}} =
        AshStorage.Operations.attach(post, :cover_image, "hello world",
          filename: "test.txt",
          content_type: "text/plain"
        )

      # Confirm no oban variant blob yet
      blob = Ash.load!(blob, :variants)
      oban_variant = Enum.find(blob.variants, &(&1.variant_name == "oban_upper"))
      # eager_upper is there but oban_upper should not be yet
      assert oban_variant == nil

      # Run the pending variants action (simulates what oban would do)
      {:ok, blob} = Ash.update(blob, %{}, action: :run_pending_variants)

      # Now the variant should exist
      blob = Ash.load!(blob, :variants)
      oban_variant = Enum.find(blob.variants, &(&1.variant_name == "oban_upper"))
      assert oban_variant != nil

      {:ok, data} = AshStorage.Service.Test.download(oban_variant.key, [])
      assert data == "HELLO WORLD"

      # Status should be updated to complete
      assert blob.metadata["__pending_variants__"]["oban_upper"]["status"] == "complete"
    end
  end
end
