defmodule CharacterSheetWeb.PlayerConfirmationControllerTest do
  use CharacterSheetWeb.ConnCase, async: true

  alias CharacterSheet.Accounts
  alias CharacterSheet.Repo
  import CharacterSheet.AccountsFixtures

  setup do
    %{player: player_fixture()}
  end

  describe "GET /players/confirm" do
    test "renders the resend confirmation page", %{conn: conn} do
      conn = get(conn, ~p"/players/confirm")
      response = html_response(conn, 200)
      assert response =~ "Resend confirmation instructions"
    end
  end

  describe "POST /players/confirm" do
    @tag :capture_log
    test "sends a new confirmation token", %{conn: conn, player: player} do
      conn =
        post(conn, ~p"/players/confirm", %{
          "player" => %{"email" => player.email}
        })

      assert redirected_to(conn) == ~p"/"

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "If your email is in our system"

      assert Repo.get_by!(Accounts.PlayerToken, player_id: player.id).context == "confirm"
    end

    test "does not send confirmation token if Player is confirmed", %{conn: conn, player: player} do
      Repo.update!(Accounts.Player.confirm_changeset(player))

      conn =
        post(conn, ~p"/players/confirm", %{
          "player" => %{"email" => player.email}
        })

      assert redirected_to(conn) == ~p"/"

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "If your email is in our system"

      refute Repo.get_by(Accounts.PlayerToken, player_id: player.id)
    end

    test "does not send confirmation token if email is invalid", %{conn: conn} do
      conn =
        post(conn, ~p"/players/confirm", %{
          "player" => %{"email" => "unknown@example.com"}
        })

      assert redirected_to(conn) == ~p"/"

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "If your email is in our system"

      assert Repo.all(Accounts.PlayerToken) == []
    end
  end

  describe "GET /players/confirm/:token" do
    test "renders the confirmation page", %{conn: conn} do
      token_path = ~p"/players/confirm/some-token"
      conn = get(conn, token_path)
      response = html_response(conn, 200)
      assert response =~ "Confirm account"

      assert response =~ "action=\"#{token_path}\""
    end
  end

  describe "POST /players/confirm/:token" do
    test "confirms the given token once", %{conn: conn, player: player} do
      token =
        extract_player_token(fn url ->
          Accounts.deliver_player_confirmation_instructions(player, url)
        end)

      conn = post(conn, ~p"/players/confirm/#{token}")
      assert redirected_to(conn) == ~p"/"

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "Player confirmed successfully"

      assert Accounts.get_player!(player.id).confirmed_at
      refute get_session(conn, :player_token)
      assert Repo.all(Accounts.PlayerToken) == []

      # When not logged in
      conn = post(conn, ~p"/players/confirm/#{token}")
      assert redirected_to(conn) == ~p"/"

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "Player confirmation link is invalid or it has expired"

      # When logged in
      conn =
        build_conn()
        |> log_in_player(player)
        |> post(~p"/players/confirm/#{token}")

      assert redirected_to(conn) == ~p"/"
      refute Phoenix.Flash.get(conn.assigns.flash, :error)
    end

    test "does not confirm email with invalid token", %{conn: conn, player: player} do
      conn = post(conn, ~p"/players/confirm/oops")
      assert redirected_to(conn) == ~p"/"

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "Player confirmation link is invalid or it has expired"

      refute Accounts.get_player!(player.id).confirmed_at
    end
  end
end
