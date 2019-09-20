alias FootballSeasons.Seasons
alias FootballSeasons.Seasons.{Game, PeriodResult}

defimpl MnesiaCacheable, for: Game do
  @attributes_whitelist [
    :id,
    :division,
    :season,
    :date,
    :hthg,
    :htag,
    :fthg,
    :ftag
  ]
  @not_existing_team_name "Team has been deleted"

  def serialize(record) do
    %{}
    |> puts_whitelisted_attributes(record)
    |> puts_period_results(record)
    |> puts_team_names(record)
  end

  defp puts_whitelisted_attributes(aggregator, record) do
    {whitelisted, _filtered} = Map.split(record, @attributes_whitelist)
    Map.merge(aggregator, whitelisted)
  end

  defp puts_period_results(aggregator, record) do
    Map.merge(aggregator, %{htr: PeriodResult.get_htr(record), ftr: PeriodResult.get_ftr(record)})
  end

  defp puts_team_names(aggregator, record) do
    Map.merge(aggregator, get_team_names(record))
  end

  defp get_team_names(%{home_team: %{name: home_team_name}, away_team: %{name: away_team_name}}) do
    %{
      home_team_name: home_team_name,
      away_team_name: away_team_name
    }
  end

  defp get_team_names(%{home_team_id: home_team_id, away_team_id: away_team_id}) do
    home_team_name = get_team_name(home_team_id)
    away_team_name = get_team_name(away_team_id)

    %{
      home_team_name: home_team_name,
      away_team_name: away_team_name
    }
  end

  defp get_team_name(team_id) do
    team_id
    |> Seasons.get_team()
    |> case do
      nil ->
        @not_existing_team_name

      %{name: team_name} ->
        team_name
    end
  end
end
