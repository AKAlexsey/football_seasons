defmodule FootballSeasons.BackgroundJobsWorker do
  @moduledoc """
  Perform background jobs eg caching games after project starting
  """

  use GenServer

  alias FootballSeasons.Caching.CacheRecordService

  @caching_timeout 3000

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_) do
    Process.send_after(self(), :cache_database, @caching_timeout)
    {:ok, %{}}
  end

  def handle_info(:cache_database, state) do
    CacheRecordService.perform()
    {:noreply, state}
  end

  # Callbacks for catching messages from Task.async in CacheRecordService.perform()
  def handle_info({_ref, :ok}, state) do
    {:noreply, state}
  end

  def handle_info({:DOWN, _ref, :process, _pid, _reason}, state) do
    {:noreply, state}
  end
end
