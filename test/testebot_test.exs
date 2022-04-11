defmodule TestebotTest do
  use ExUnit.Case
  doctest Testebot

  test "greets the world" do
    assert Testebot.hello() == :world
  end
end
