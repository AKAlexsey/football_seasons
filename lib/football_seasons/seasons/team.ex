defmodule FootballSeasons.Seasons.Team do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias FootballSeasons.Seasons.Game

  @type t :: %__MODULE__{}

  @cast_fields [:name]
  @required_fields [:name]

  schema "teams" do
    field :name, :string
    has_many :home_games, {"games", Game}, foreign_key: :home_team_id
    has_many :away_games, {"games", Game}, foreign_key: :away_team_id

    timestamps()
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, @cast_fields)
    |> validate_required(@required_fields)
  end
end
