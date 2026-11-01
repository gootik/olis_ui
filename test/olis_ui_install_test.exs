defmodule OlisUI.InstallTest do
  use ExUnit.Case, async: true

  setup do
    base = Path.join(System.tmp_dir!(), "olis-ui-install-#{System.unique_integer([:positive])}")
    project = Path.join(base, "dashboard")
    library = Path.join(base, "olis-components")

    for relative <- ["assets/css", "assets/js"] do
      File.mkdir_p!(Path.join(project, relative))
      File.mkdir_p!(Path.join(library, relative))
    end

    File.write!(Path.join(project, "assets/css/app.css"), "/* application styles */")
    File.write!(Path.join(project, "assets/js/app.js"), "// application entry")
    File.mkdir_p!(Path.join(library, "assets/css/foundation"))
    File.write!(Path.join(library, "assets/css/foundation/index.css"), "/* foundation */")
    File.write!(Path.join(library, "assets/css/olis_ui.css"), "/* library styles */")
    File.write!(Path.join(library, "assets/js/olis_ui_setup.js"), "// library setup")

    on_exit(fn -> File.rm_rf!(base) end)
    %{project: project, library: library}
  end

  test "creates portable asset entry points without changing the application", context do
    assert [{:created, css_path}, {:created, js_path}] =
             OlisUI.Install.write_assets!(context.project, context.library)

    css = File.read!(css_path)
    js = File.read!(js_path)
    assert css =~ ~s(@import "tailwindcss";)
    assert css =~ ~s(@import "../../../olis-components/assets/css/foundation/index.css";)
    assert css =~ ~s(@import "../../../olis-components/assets/css/olis_ui.css";)
    refute css =~ "@heroui/styles"

    [tailwind, animations, foundation, overrides] =
      css |> String.split("\n") |> Enum.filter(&String.starts_with?(&1, "@import"))

    assert tailwind == ~s(@import "tailwindcss";)
    assert animations == ~s(@import "tw-animate-css";)
    assert foundation =~ "/foundation/index.css"
    assert overrides =~ "/olis_ui.css"
    assert css =~ ~s(@source "../../../olis-components/lib";)

    assert js =~
             ~s(import { createOlisUI } from "../../../olis-components/assets/js/olis_ui_setup.js";)

    assert js =~ "export const olisUI = createOlisUI(Alpine, collapse);"

    assert File.read!(Path.join(context.project, "assets/css/app.css")) ==
             "/* application styles */"

    assert File.read!(Path.join(context.project, "assets/js/app.js")) == "// application entry"
  end

  test "is repeatable and preserves locally edited entry points", context do
    [{:created, css_path}, {:created, _js_path}] =
      OlisUI.Install.write_assets!(context.project, context.library)

    assert [{:unchanged, _}, {:unchanged, _}] =
             OlisUI.Install.write_assets!(context.project, context.library)

    File.write!(css_path, "/* custom entry */")

    assert [{:preserved, ^css_path}, {:unchanged, _}] =
             OlisUI.Install.write_assets!(context.project, context.library)

    assert File.read!(css_path) == "/* custom entry */"
  end

  test "reports a missing bundled foundation before creating entry points", context do
    File.rm!(Path.join(context.library, "assets/css/foundation/index.css"))

    assert_raise ArgumentError, ~r/OlisUI asset not found: .*foundation\/index\.css/, fn ->
      OlisUI.Install.write_assets!(context.project, context.library)
    end

    refute File.exists?(Path.join(context.project, "assets/css/olis_ui.css"))
    refute File.exists?(Path.join(context.project, "assets/js/olis_ui.js"))
  end

  test "explains when the Phoenix asset entry points are absent", context do
    File.rm!(Path.join(context.project, "assets/js/app.js"))

    assert_raise ArgumentError, ~r/expected .*assets\/js\/app\.js/, fn ->
      OlisUI.Install.write_assets!(context.project, context.library)
    end
  end
end
