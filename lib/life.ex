defmodule Life do
  @moduledoc """
  Life implementation in Elixir. This module will be used to spawn different patterns.
  """

  @spec still_life() :: :ok
  def still_life do
    Enum.each([{1, 0}, {0, 1}, {1, 1}, {-1, -1}], &Life.Supervisors.Cell.spawn/1)
  end
end
