defmodule FootballSeasonsWeb.FileController do
  use FootballSeasonsWeb, :controller

  alias FootballSeasons.Seasons.GamesFromCsvFileService

  def new(conn, _params) do
    render(conn, "new.html", file: :file)
  end

  def create(conn, %{"file" => %{"csv_file" => plug_upload}}) do
    case GamesFromCsvFileService.perform(plug_upload) do
      {:ok, file_name} ->
        conn
        |> put_flash(:info, "#{file_name} uploaded successfully.")
        |> redirect(to: Routes.game_path(conn, :index))

      {:error, reason} ->
        conn
        |> put_flash(:error, "#{reason}")
        |> redirect(to: Routes.file_path(conn, :new))
    end
  end
end
