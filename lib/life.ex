defmodule Life do
  @moduledoc false

  def still_life do
    Enum.each([{1, 0}, {0, 1}, {1, 1}, {-1, -1}], &Life.Supervisors.Cell.spawn/1)
  end
end
