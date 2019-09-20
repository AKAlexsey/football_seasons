defmodule Mix.Tasks.ResetMnesiaSchema do
  @moduledoc """
  Remove old and create new mnesia schema for providing index mnesia table search
  """

  @shortdoc "Remove old and create new mnesia schema for providing index mnesia table search"

  use Mix.Task

  alias FootballSeasons.Caching.Game

  def run(_) do
    File.rm_rf("#{File.cwd!()}/#{Application.get_env(:mnesia, :dir)}")
    Memento.Schema.create([Node.self()])
    :mnesia.start()
    Memento.Table.create(Game)
    :mnesia.stop()
  end
end
