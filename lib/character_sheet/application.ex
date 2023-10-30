defmodule CharacterSheet.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      CharacterSheetWeb.Telemetry,
      # Start the Ecto repository
      CharacterSheet.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: CharacterSheet.PubSub},
      # Start Finch
      {Finch, name: CharacterSheet.Finch},
      # Start the Endpoint (http/https)
      CharacterSheetWeb.Endpoint
      # Start a worker by calling: CharacterSheet.Worker.start_link(arg)
      # {CharacterSheet.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CharacterSheet.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CharacterSheetWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
