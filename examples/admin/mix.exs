defmodule OlisAdmin.MixProject do
  use Mix.Project

  def project do
    [
      app: :olis_admin,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [extra_applications: [:logger, :runtime_tools], mod: {OlisAdmin.Application, []}]
  end

  defp deps do
    [
      {:olis_ui, path: "../.."},
      {:phoenix, "~> 1.7"},
      {:phoenix_live_view, "~> 1.0"},
      {:phoenix_html, "~> 4.0"},
      {:bandit, "~> 1.0"},
      {:jason, "~> 1.4"}
    ]
  end
end
