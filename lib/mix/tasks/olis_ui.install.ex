defmodule Mix.Tasks.OlisUi.Install do
  use Mix.Task

  @shortdoc "Creates OlisUI asset entry points for a Phoenix application"

  @moduledoc """
  Creates `assets/css/olis_ui.css` and `assets/js/olis_ui.js` in a Phoenix app.

  Add `{:olis_ui, ...}` to the application's dependencies and run `mix deps.get`
  first. Existing entry points are never overwritten.
  """

  @impl Mix.Task
  def run(args) do
    {options, remaining, invalid} = OptionParser.parse(args, strict: [help: :boolean])

    if invalid != [] or remaining != [] do
      Mix.raise("Usage: mix olis_ui.install")
    end

    if options[:help] do
      Mix.shell().info(@moduledoc)
    else
      install!()
    end
  end

  defp install! do
    library_dir = Mix.Project.deps_paths()[:olis_ui]

    unless library_dir do
      Mix.raise("Add :olis_ui to your dependencies and run mix deps.get first.")
    end

    results = OlisUI.Install.write_assets!(File.cwd!(), library_dir)

    for {status, path} <- results do
      Mix.shell().info("#{status}: #{Path.relative_to_cwd(path)}")
    end

    Mix.shell().info("""

    Next steps:

      1. In assets/, run:
         npm install --save-exact alpinejs@3.17.5 @alpinejs/collapse@3.17.5 tw-animate-css@1.4.0

      2. In assets/css/app.css, replace the Tailwind import with:
         @import "./olis_ui.css";
         Keep the rest of your app's sources and styles.

      3. In assets/js/app.js, import and start OlisUI before connecting LiveSocket:
         import { olisUI } from "./olis_ui";
         olisUI.start();

         Add this callback to the existing LiveSocket options, composing it with
         any callback you already have:
         dom: { onBeforeElUpdated: olisUI.beforeUpdate }

      4. Use <OlisUI.button>Save</OlisUI.button> or import OlisUI in your HTML
         helpers. If CoreComponents is already imported, resolve the button,
         input, and header name conflicts before using unqualified names.

    If an existing CSS entry point was preserved, replace its old stylesheet
    package import with the Tailwind and bundled foundation imports shown in
    the README migration instructions. Keep its existing source paths and
    application customizations. Review all preserved entry points before use.
    """)
  end
end
