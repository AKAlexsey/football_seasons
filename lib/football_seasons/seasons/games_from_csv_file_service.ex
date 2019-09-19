NimbleCSV.define(GamesFileParser, separator: ",", escape: "\"")

defmodule FootballSeasons.Seasons.GamesFromCsvFileService do
  @moduledoc """
  Parse CSV file and create games by it's data
  """

  @date_format "{D}/{0M}/{YYYY}"

  alias FootballSeasons.Seasons
  alias FootballSeasons.Seasons.Game

  @doc """
  Perform parsing file and creating records in 'games' table
  Return {:ok, file_name.csv} in case of success
  Return {:error, binary_written_reason} in case of error
  """
  @spec perform(Plug.Upload.t()) :: {:ok, binary} | {:error, binary}
  def perform(%Plug.Upload{path: path, filename: filename}) do
    with {:file_extension, ".csv"} <- {:file_extension, Path.extname(filename)},
         file_stream <- file_to_stream(path),
         :ok <- create_games(file_stream) do
      {:ok, filename}
    else
      {:file_extension, actual_extension} ->
        {:error, "Wrong file extension. Expected: '.csv', given: #{actual_extension}"}

      {:error, reason} ->
        {:error, reason}

      unknown_error ->
        {:error, "Unknown error #{inspect(unknown_error)}"}
    end
  end

  def perform(input) do
    {:error, "Wrong argument format. Expected: %Plug.Upload{}, given: #{inspect(input)}"}
  end

  defp file_to_stream(file_path) do
    file_path
    |> File.stream!()
    |> GamesFileParser.parse_stream()
  end

  defp create_games(file_stream) do
    file_stream
    |> Enum.reduce_while(:ok, fn [
                                   _id,
                                   division,
                                   season,
                                   string_date,
                                   home_team,
                                   away_team,
                                   fthg,
                                   ftag,
                                   _ftr,
                                   hthg,
                                   htag,
                                   _htr
                                 ],
                                 _result ->
      with {:ok, %{id: home_team_id}} <- Seasons.find_or_create_team_by_name(home_team),
           {:ok, %{id: away_team_id}} <- Seasons.find_or_create_team_by_name(away_team),
           {:ok, date} <- Timex.parse(string_date, @date_format),
           {:ok, %Game{}} <-
             Seasons.create_game(%{
               division: division,
               season: season,
               date: date,
               home_team_id: home_team_id,
               away_team_id: away_team_id,
               fthg: fthg,
               ftag: ftag,
               hthg: hthg,
               htag: htag
             }) do
        {:cont, :ok}
      else
        {:error, %Ecto.Changeset{} = changeset} ->
          {:halt, {:error, "Changeset error #{inspect(changeset)}"}}

        {:error, reason} ->
          {:halt, {:error, reason}}
      end
    end)
  end
end
