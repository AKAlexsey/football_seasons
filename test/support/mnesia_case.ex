defmodule FootballSeasons.MnesiaCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate
  alias FootballSeasons.Caching.Game

  using do
    quote do
      import FootballSeasons.MnesiaFixtures
      alias FootballSeasons.Caching.Game
    end
  end

  setup _tags do
    on_exit(fn ->
      Memento.transaction(fn ->
        Game
        |> Memento.Query.all()
        |> (fn games ->
              games
              |> Enum.each(fn game ->
                Memento.Query.delete_record(game)
              end)
            end).()
      end)
    end)

    :ok
  end
end
