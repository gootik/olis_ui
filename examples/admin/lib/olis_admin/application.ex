defmodule OlisAdmin.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Phoenix.PubSub, name: OlisAdmin.PubSub},
      OlisAdminWeb.Endpoint
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: OlisAdmin.Supervisor)
  end

  @impl true
  def config_change(changed, _new, removed) do
    OlisAdminWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
