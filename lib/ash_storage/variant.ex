defmodule AshStorage.Variant do
  @moduledoc """
  Behaviour for file variants that transform files into other files.

  Variants generate transformed versions of uploaded files — image thumbnails,
  PDF previews, video thumbnails, format conversions, etc.

  ## Implementing a Variant

      defmodule MyApp.Storage.Thumbnail do
        @behaviour AshStorage.Variant

        @impl true
        def accept?(content_type), do: String.starts_with?(content_type, "image/")

        @impl true
        def transform(source_path, dest_path, opts) do
          width = Keyword.get(opts, :width, 200)
          height = Keyword.get(opts, :height, 200)
          # Use an image library to resize
          Image.thumbnail!(source_path, "\#{width}x\#{height}", crop: :center)
          |> Image.write!(dest_path)
          {:ok, %{content_type: "image/webp"}}
        end
      end
  """

  @doc """
  Returns true if this variant can handle the given content type.
  """
  @callback accept?(content_type :: String.t()) :: boolean()

  @doc """
  Transform a file and write the result.

  Reads the file at `source_path`, applies the transformation, and writes the
  result to `dest_path`. Returns `{:ok, metadata}` where metadata is a map
  that can include:

  - `:content_type` — the MIME type of the output file
  - `:filename` — override filename for the variant blob

  Any other keys are stored in the variant blob's metadata.
  """
  @callback transform(
              source_path :: String.t(),
              dest_path :: String.t(),
              opts :: keyword()
            ) :: {:ok, map()} | {:error, term()}
end
