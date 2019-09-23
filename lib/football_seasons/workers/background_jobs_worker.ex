defmodule FootballSeasons.BackgroundJobsWorker do
  @moduledoc """
  Perform background jobs eg caching games after project starting
  """

  use GenServer

  alias FootballSeasons.Caching.CacheRecordService
  alias FootballSeasons.Tasks.MigrateDatabase

  @migrate_timeout 2000
  @caching_timeout 5000

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_) do
    Process.send_after(self(), :migrate_database, @migrate_timeout)
    Process.send_after(self(), :cache_database, @caching_timeout)
    {:ok, %{}}
  end

  def handle_info(:migrate_database, state) do
    MigrateDatabase.run()
    {:noreply, state}
  end

  def handle_info(:cache_database, state) do
    CacheRecordService.reset_mnesia()
    CacheRecordService.cache_games()
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
