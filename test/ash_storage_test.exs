defmodule AshStorageTest do
  use ExUnit.Case
  doctest AshStorage

  test "greets the world" do
    assert AshStorage.hello() == :world
  end
end
