defmodule Life.Supervisors.Cell do
  @moduledoc false

  use DynamicSupervisor

  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_state) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def remove(pid) do
    DynamicSupervisor.terminate_child(__MODULE__, pid)
  end

  def spawn(position) do
    DynamicSupervisor.start_child(__MODULE__, {Life.Cell, [position]})
  end

  def children do
    __MODULE__
    |> Supervisor.which_children()
    |> Enum.map(fn {_, pid, _, _} -> pid end)
  end
end
