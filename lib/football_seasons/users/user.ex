defmodule FootballSeasons.Users.User do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @cast_fields [:email, :name, :password_hash, :password, :is_admin]
  @required_fields [:email, :name, :is_admin]
  @type t :: %__MODULE__{}

  schema "users" do
    field :email, :string
    field :is_admin, :boolean, default: false
    field :name, :string
    field :password, :string, virtual: true
    field :password_hash, :string

    timestamps()
  end

  def registration_changeset(struct, params) do
    struct
    |> changeset(params)
    |> cast(params, [:password], [])
    |> validate_length(:password, min: 6, max: 100)
    |> hash_password
  end

  defp hash_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(
          changeset,
          :password_hash,
          Bcrypt.hash_pwd_salt(password)
        )

      _ ->
        changeset
    end
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, @cast_fields)
    |> validate_required(@required_fields)
  end
end
