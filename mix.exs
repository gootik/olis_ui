defmodule HeroUI.MixProject do
  use Mix.Project

  def project do
    [
      app: :hero_ui,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      description: "HeroUI-inspired components for Phoenix LiveView"
    ]
  end

  def application, do: [extra_applications: [:logger]]
  defp elixirc_paths(:dev), do: ["lib", "preview"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix_live_view, "~> 1.0"},
      {:jason, "~> 1.4"},
      {:bandit, "~> 1.0", only: :dev},
      {:tailwind, "~> 0.3", runtime: Mix.env() == :dev}
    ]
  end
end
