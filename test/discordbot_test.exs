defmodule DiscordbotTest do
  use ExUnit.Case
  doctest Discordbot

  test "greets the world" do
    assert Discordbot.hello() == :world
  end
end
