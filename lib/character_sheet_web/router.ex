defmodule CharacterSheetWeb.Router do
  use CharacterSheetWeb, :router

  import CharacterSheetWeb.PlayerAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {CharacterSheetWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_player
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CharacterSheetWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", CharacterSheetWeb do
  #   pipe_through :api
  # end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:character_sheet, :dev_routes) do

    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", CharacterSheetWeb do
    pipe_through [:browser, :redirect_if_player_is_authenticated]

    get "/players/register", PlayerRegistrationController, :new
    post "/players/register", PlayerRegistrationController, :create
    get "/players/log_in", PlayerSessionController, :new
    post "/players/log_in", PlayerSessionController, :create
    get "/players/reset_password", PlayerResetPasswordController, :new
    post "/players/reset_password", PlayerResetPasswordController, :create
    get "/players/reset_password/:token", PlayerResetPasswordController, :edit
    put "/players/reset_password/:token", PlayerResetPasswordController, :update
  end

  scope "/", CharacterSheetWeb do
    pipe_through [:browser, :require_authenticated_player]

    get "/players/settings", PlayerSettingsController, :edit
    put "/players/settings", PlayerSettingsController, :update
    get "/players/settings/confirm_email/:token", PlayerSettingsController, :confirm_email
  end

  scope "/", CharacterSheetWeb do
    pipe_through [:browser]

    delete "/players/log_out", PlayerSessionController, :delete
    get "/players/confirm", PlayerConfirmationController, :new
    post "/players/confirm", PlayerConfirmationController, :create
    get "/players/confirm/:token", PlayerConfirmationController, :edit
    post "/players/confirm/:token", PlayerConfirmationController, :update
  end
end
