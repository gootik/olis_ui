defmodule OlisUI.Install do
  @moduledoc false

  @doc "Creates the asset entry points used by the installation task without overwriting edits."
  def write_assets!(project_dir, library_dir) do
    css_dir = Path.join(project_dir, "assets/css")
    js_dir = Path.join(project_dir, "assets/js")

    css = """
    @import "tailwindcss";
    @import "tw-animate-css";
    @import "#{Path.relative_to(Path.join(library_dir, "assets/css/foundation/index.css"), css_dir, force: true)}";
    @import "#{Path.relative_to(Path.join(library_dir, "assets/css/olis_ui.css"), css_dir, force: true)}";
    @source "#{Path.relative_to(Path.join(library_dir, "lib"), css_dir, force: true)}";
    @source "#{Path.relative_to(Path.join(library_dir, "assets/js"), css_dir, force: true)}";
    """

    javascript = """
    import Alpine from "alpinejs";
    import collapse from "@alpinejs/collapse";
    import { createOlisUI } from "./#{Path.relative_to(Path.join(library_dir, "assets/js/olis_ui_setup.js"), js_dir, force: true)}";

    export const olisUI = createOlisUI(Alpine, collapse);
    """

    [
      write_if_missing!(Path.join(css_dir, "olis_ui.css"), css),
      write_if_missing!(Path.join(js_dir, "olis_ui.js"), javascript)
    ]
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
