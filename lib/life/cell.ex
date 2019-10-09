defmodule Life.Cell do
  @moduledoc false

  use GenServer

  @offsets [
    {-1, -1},
    {-1, 0},
    {-1, 1},
    {1, 1},
    {1, 0},
    {1, -1},
    {0, -1},
    {0, 1}
  ]

  def start_link([position]) do
    GenServer.start_link(__MODULE__, position,
      name: {:via, Registry, {Life.Cell.Registry, position}}
    )
  end

  def tick(pid) do
    GenServer.call(pid, :tick)
  end

  def position(pid) do
    GenServer.call(pid, :position)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  # See game rules for this function's logic.
  @impl true
  def handle_call(:tick, _from, position_in_map) do
    to_remove =
      position_in_map
      |> count_neighbours()
      |> case do
        neighbours when neighbours not in [2, 3] -> [self()]
        _ -> []
      end

    to_spawn =
      position_in_map
      |> neighbours_positions()
      |> Stream.reject(&is_alive/1)
      |> Enum.filter(&(count_neighbours(&1) == 3))

    {:reply, {to_remove, to_spawn}, position_in_map}
  end

  @impl true
  def handle_call(:position, _from, position) do
    {:reply, position, position}
  end

  defp count_neighbours(position) do
    position
    |> neighbours_positions()
    |> Enum.filter(&is_alive/1)
    |> length()
  end

  defp neighbours_positions({x, y}) do
    Enum.map(@offsets, fn {dx, dy} -> {x + dx, y + dy} end)
  end

  defp is_alive(position_identifier) do
    Life.Cell.Registry
    |> Registry.lookup(position_identifier)
    |> case do
      [{pid, _}] -> Process.alive?(pid)
      _ -> false
    end
  end
end
