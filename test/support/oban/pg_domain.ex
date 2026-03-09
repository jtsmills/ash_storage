defmodule AshStorage.Test.PgDomain do
  @moduledoc false
  use Ash.Domain

  resources do
    resource AshStorage.Test.PgPost
    resource AshStorage.Test.PgBlob
    resource AshStorage.Test.PgAttachment
  end
end
