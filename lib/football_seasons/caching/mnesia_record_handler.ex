defmodule FootballSeasons.Caching.MnesiaRecordHandler do
  @moduledoc """
  Prepare record data for sending to mnesia handler and pass data to appropriate handler.
  """

  alias FootballSeasons.Caching.MnesiaRecordHandler.GameHandler
  alias FootballSeasons.Seasons.Game

  def perform(action, record) do
    action
    |> handler_data(record)
    |> pass_data_to_handler()
  end

  defp handler_data(action, record) do
    %{__struct__: model_name} = record

    %{
      action: action,
      model_name: model_name,
      attributes: MnesiaCacheable.serialize(record)
    }
  end

  defp pass_data_to_handler(%{action: action, model_name: Game, attributes: attributes}) do
    GameHandler.handle(action, attributes)
  end

  defp pass_data_to_handler(%{model_name: model_name} = data) do
    raise "Unknown model_name: #{inspect(model_name)} in #{__MODULE__} given data: #{inspect(data)}"
  end
end
