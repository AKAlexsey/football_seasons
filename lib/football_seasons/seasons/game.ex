defmodule FootballSeasons.Seasons.Game do
  @moduledoc false

  use Ecto.Schema
  use Observable, :notifier

  import Ecto.Changeset

  alias FootballSeasons.CacheRecordObserver
  alias FootballSeasons.Seasons.Team

  @type t :: %__MODULE__{}

  @cast_fields [
    :division,
    :season,
    :date,
    :home_team_id,
    :away_team_id,
    :fthg,
    :ftag,
    :hthg,
    :htag
  ]
  @required_fields [
    :division,
    :season,
    :date,
    :home_team_id,
    :away_team_id,
    :fthg,
    :ftag,
    :hthg,
    :htag
  ]

  schema "games" do
    field :division, :string
    field :season, :string
    field :date, :date
    belongs_to :home_team, Team, foreign_key: :home_team_id
    belongs_to :away_team, Team, foreign_key: :away_team_id
    field :fthg, :integer
    field :ftag, :integer
    field :hthg, :integer
    field :htag, :integer

    timestamps()
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, @cast_fields)
    |> validate_required(@required_fields)
  end

  observations do
    action(:insert, [CacheRecordObserver])
    action(:update, [CacheRecordObserver])
    action(:delete, [CacheRecordObserver])
  end
end
