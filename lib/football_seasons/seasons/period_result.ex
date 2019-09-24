defmodule FootballSeasons.Seasons.PeriodResult do
  @moduledoc """
  Perform HTR and FTR calculation
  """

  @draw "draw"
  @home "home"
  @away "away"

  def enum_list, do: [@draw, @home, @away]

  @spec get_htr(map()) :: binary()
  def get_htr(%{hthg: hthg, htag: htag}) do
    cond do
      hthg == htag -> @draw
      hthg > htag -> @home
      hthg < htag -> @away
    end
  end

  @spec get_ftr(map()) :: binary()
  def get_ftr(%{fthg: fthg, ftag: ftag}) do
    cond do
      fthg == ftag -> @draw
      fthg > ftag -> @home
      fthg < ftag -> @away
    end
  end
end
