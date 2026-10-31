defmodule Mix.Tasks.Admin do
  @moduledoc false
  use Mix.Task

  @shortdoc "Builds the dashboard stylesheet and starts the sample app"
  @repo_root Path.expand("../../../../..", __DIR__)
  @app_root Path.expand("../../..", __DIR__)

  @impl true
  def run(_) do
    tailwind = Path.join(@repo_root, "node_modules/.bin/tailwindcss")

    unless File.exists?(tailwind) do
      Mix.raise("Tailwind is missing. Run npm ci in the repository root first.")
    end

    File.mkdir_p!(Path.join(@app_root, "priv/static"))

    {output, status} =
      System.cmd(tailwind, ["-i", "assets/css/app.css", "-o", "priv/static/app.css"],
        cd: @app_root,
        stderr_to_stdout: true
      )

    Mix.shell().info(output)

    if status != 0 do
      Mix.raise("Could not build the dashboard stylesheet")
    end

    File.cp!(Path.join(@app_root, "assets/js/app.js"), Path.join(@app_root, "priv/static/app.js"))

    Mix.Task.run("app.start")

    Mix.shell().info(
      "Admin dashboard available at http://localhost:#{System.get_env("PORT", "4001")}"
    )

    Process.sleep(:infinity)
  end
end
