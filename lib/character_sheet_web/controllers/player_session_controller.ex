defmodule CharacterSheetWeb.PlayerSessionController do
  use CharacterSheetWeb, :controller

  alias CharacterSheet.Accounts
  alias CharacterSheetWeb.PlayerAuth

  def new(conn, _params) do
    render(conn, :new, error_message: nil)
  end

  def create(conn, %{"player" => player_params}) do
    %{"email" => email, "password" => password} = player_params

    if player = Accounts.get_player_by_email_and_password(email, password) do
      conn
      |> put_flash(:info, "Welcome back!")
      |> PlayerAuth.log_in_player(player, player_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      render(conn, :new, error_message: "Invalid email or password")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> PlayerAuth.log_out_player()
  end
end
