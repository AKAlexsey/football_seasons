defmodule FootballSeasonsWeb.GameView do
  use FootballSeasonsWeb, :view

  alias FootballSeasons.Seasons
  import FootballSeasons.Seasons.PeriodResult, only: [get_htr: 1, get_ftr: 1]

  @spec teams_select_list :: list(tuple)
  def teams_select_list do
    Seasons.list_teams()
    |> Enum.map(fn %{id: id, name: name} -> {name, id} end)
  end
end
