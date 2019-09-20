defmodule FootballSeasons.Seasons.PeriodResult do
  @moduledoc """
  Perform HTR and FTR calculation
  """

  @draw "draw"
  @home "home"
  @away "away"

  alias FootballSeasons.Seasons.Game

  def enum_list, do: [@draw, @home, @away]

  @spec get_htr(Game.t()) :: binary()
  def get_htr(%Game{hthg: hthg, htag: htag}) do
    cond do
      hthg == htag -> @draw
      hthg > htag -> @home
      hthg < htag -> @away
    end
  end

  @spec get_ftr(Game.t()) :: binary()
  def get_ftr(%Game{fthg: fthg, ftag: ftag}) do
    cond do
      fthg == ftag -> @draw
      fthg > ftag -> @home
      fthg < ftag -> @away
    end
  end
end
