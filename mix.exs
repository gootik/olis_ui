defmodule OlisUI.MixProject do
  use Mix.Project

  def project do
    [
      app: :olis_ui,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      description: "OlisUI components for Phoenix LiveView",
      package: [
        licenses: ["Apache-2.0"],
        links: %{"GitHub" => "https://github.com/gootik/olis_ui"},
        files:
          ~w(lib assets docs/reference.md LICENSE LICENSES README.md THIRD_PARTY_NOTICES.md mix.exs)
      ]
    ]
  end

  def application, do: [extra_applications: [:logger]]
  defp elixirc_paths(:dev), do: ["lib", "preview"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix_live_view, "~> 1.0"},
      {:jason, "~> 1.4"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:bandit, "~> 1.0", only: :dev},
      {:tailwind, "~> 0.3", runtime: Mix.env() == :dev}
    ]
  end
end
