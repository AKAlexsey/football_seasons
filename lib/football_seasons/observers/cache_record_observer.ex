defmodule FootballSeasons.CacheRecordObserver do
  @moduledoc """
  Send record attributes and action data to MnesiaRecordHandler.
  """

  use Observable, :observer

  alias FootballSeasons.Caching.MnesiaRecordHandler

  def handle_notify(action, {_repo, _old, record}) do
    Task.async(fn ->
      MnesiaRecordHandler.perform(action, record)
    end)

    :ok
  end
end
