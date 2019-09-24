defmodule Mix.Tasks.ResetMnesiaSchema do
  @moduledoc """
  Remove old and create new mnesia schema for providing index mnesia table search
  """

  @shortdoc "Remove old and create new mnesia schema for providing index mnesia table search"

  use Mix.Task

  alias FootballSeasons.Caching.CacheRecordService

  def run(_) do
    CacheRecordService.reset_mnesia()
  end
end
