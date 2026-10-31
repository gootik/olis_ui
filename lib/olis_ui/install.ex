defmodule OlisUI.Install do
  @moduledoc false

  @doc "Creates the asset entry points used by the installation task without overwriting edits."
  def write_assets!(project_dir, library_dir) do
    css_dir = Path.join(project_dir, "assets/css")
    js_dir = Path.join(project_dir, "assets/js")

    for {directory, filename} <- [{css_dir, "app.css"}, {js_dir, "app.js"}] do
      unless File.regular?(Path.join(directory, filename)) do
        raise ArgumentError, "expected #{Path.join(directory, filename)} in the Phoenix project"
      end
    end

    for relative <- [
          "assets/css/foundation/index.css",
          "assets/css/olis_ui.css",
          "assets/js/olis_ui_setup.js"
        ] do
      unless File.regular?(Path.join(library_dir, relative)) do
        raise ArgumentError, "OlisUI asset not found: #{Path.join(library_dir, relative)}"
      end
    end

    css = """
    @import "tailwindcss";
    @import #{quoted_path(Path.join(library_dir, "assets/css/foundation/index.css"), css_dir)};
    @import #{quoted_path(Path.join(library_dir, "assets/css/olis_ui.css"), css_dir)};
    @source #{quoted_path(Path.join(library_dir, "lib"), css_dir)};
    @source #{quoted_path(Path.join(library_dir, "assets/js"), css_dir)};
    """

    javascript = """
    import Alpine from "alpinejs";
    import collapse from "@alpinejs/collapse";
    import { createOlisUI } from #{quoted_path(Path.join(library_dir, "assets/js/olis_ui_setup.js"), js_dir)};

    export const olisUI = createOlisUI(Alpine, collapse);
    """

    [
      write_if_missing!(Path.join(css_dir, "olis_ui.css"), css),
      write_if_missing!(Path.join(js_dir, "olis_ui.js"), javascript)
    ]
  end

  defp quoted_path(target, base) do
    relative = Path.relative_to(target, base, force: true)

    relative =
      if String.starts_with?(relative, ".") do
        relative
      else
        "./" <> relative
      end

    Jason.encode!(relative)
  end

  defp write_if_missing!(path, contents) do
    case File.read(path) do
      {:ok, ^contents} ->
        {:unchanged, path}

      {:ok, _existing} ->
        {:preserved, path}

      {:error, :enoent} ->
        File.write!(path, contents, [:exclusive])
        {:created, path}

      {:error, reason} ->
        raise File.Error, reason: reason, action: "read", path: path
    end
  end
end
