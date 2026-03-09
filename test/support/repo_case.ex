defmodule AshStorage.RepoCase do
  @moduledoc false
  use ExUnit.CaseTemplate

  alias Ecto.Adapters.SQL.Sandbox

  using do
    quote do
      alias AshStorage.TestRepo
    end
  end

  setup tags do
    :ok = Sandbox.checkout(AshStorage.TestRepo)

    if !tags[:async] do
      Sandbox.mode(AshStorage.TestRepo, {:shared, self()})
    end

    :ok
  end
end
