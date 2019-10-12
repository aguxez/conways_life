defmodule Life.Environment do
  @moduledoc false

  use GenServer

  alias Life.Supervisors

  def start_link(_arg) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(state) do
    :timer.send_interval(2000, self(), :tick)
    {:ok, state}
  end

  @impl true
  def handle_info(:tick, state) do
    Supervisors.Cell.children()
    |> print_current_state()
    |> ping_cells()
    |> parse_ping_response()

    {:noreply, state}
  end

  # TODO: Print somewhere so we can see the actual output

  defp print_current_state(live_cells) do
    positions = Enum.map(live_cells, &Life.Cell.position/1)

    IO.inspect(positions)

    live_cells
  end

  defp ping_cells(live_cells) do
    Task.async_stream(live_cells, fn pid -> Life.Cell.tick(pid) end, max_concurrency: 50)
  end

  defp parse_ping_response(new_cells) do
    new_cells
    |> Enum.into([], fn {:ok, response} -> response end)
    |> Enum.reduce({[], []}, &identify_cells_action/2)
    |> kill_and_spawn()
  end

  defp identify_cells_action({remove, spawn}, {acc_remove, acc_spawn}) do
    {acc_remove ++ remove, acc_spawn ++ spawn}
  end

  defp kill_and_spawn({kill, spawn}) do
    Enum.each(kill, &Life.Supervisors.Cell.remove/1)
    Enum.each(spawn, &Life.Supervisors.Cell.spawn/1)
  end
end
