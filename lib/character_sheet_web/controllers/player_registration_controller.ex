defmodule CharacterSheetWeb.PlayerRegistrationController do
  use CharacterSheetWeb, :controller

  alias CharacterSheet.Accounts
  alias CharacterSheet.Accounts.Player
  alias CharacterSheetWeb.PlayerAuth

  def new(conn, _params) do
    changeset = Accounts.change_player_registration(%Player{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"player" => player_params}) do
    case Accounts.register_player(player_params) do
      {:ok, player} ->
        {:ok, _} =
          Accounts.deliver_player_confirmation_instructions(
            player,
            &url(~p"/players/confirm/#{&1}")
          )

        conn
        |> put_flash(:info, "Player created successfully.")
        |> PlayerAuth.log_in_player(player)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end
end
