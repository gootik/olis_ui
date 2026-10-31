unless Code.ensure_loaded?(OlisUI.Preview.Endpoint),
  do: Code.require_file("../preview/live_preview.ex", __DIR__)

unless Code.ensure_loaded?(OlisUI.Preview.Router),
  do: Code.require_file("../preview/preview.ex", __DIR__)

defmodule OlisUI.PreviewAlpineModulesTest do
  use ExUnit.Case, async: true
  import Plug.Test
  import Plug.Conn, only: [get_resp_header: 2]

  test "the preview serves each Alpine provider and rejects invalid or missing names" do
    directory = Path.join([File.cwd!(), "assets", "js", "alpine"])
    modules = Path.wildcard(Path.join(directory, "*.js"))
    assert modules != []
    index = conn(:get, "/olis_ui_alpine.js") |> OlisUI.Preview.Router.call([])
    assert index.status == 200

    imported =
      Regex.scan(~r/from "\.\/alpine\/([a-z0-9_]+\.js)"/, index.resp_body,
        capture: :all_but_first
      )
      |> List.flatten()
      |> Enum.sort()

    assert imported != []
    assert Enum.all?(imported, &(&1 in Enum.map(modules, fn path -> Path.basename(path) end)))

    root_imports =
      Regex.scan(~r/from "\.\/([a-z0-9_]+\.js)"/, index.resp_body, capture: :all_but_first)
      |> List.flatten()

    for dependency <- root_imports do
      assert (conn(:get, "/" <> dependency) |> OlisUI.Preview.Router.call([])).status == 200
    end

    for path <- modules do
      response = conn(:get, "/alpine/" <> Path.basename(path)) |> OlisUI.Preview.Router.call([])
      assert response.status == 200
      assert response.resp_body == File.read!(path)
      assert get_resp_header(response, "content-type") |> hd() =~ "text/javascript"

      dependencies =
        Regex.scan(~r/from "\.\.\/([a-z0-9_]+\.js)"/, response.resp_body, capture: :all_but_first)
        |> List.flatten()

      for dependency <- dependencies do
        assert (conn(:get, "/" <> dependency) |> OlisUI.Preview.Router.call([])).status == 200
      end
    end

    for path <- ["/alpine/__missing__.js", "/alpine/invalid.name.js"] do
      assert (conn(:get, path) |> OlisUI.Preview.Router.call([])).status == 404
    end
  end

  test "the preview serves its local font files and rejects unknown paths" do
    stylesheet = conn(:get, "/preview-fonts/index.css") |> OlisUI.Preview.Router.call([])
    assert stylesheet.status == 200

    files =
      Regex.scan(~r|url\(\./files/([^)]*)\)|, stylesheet.resp_body, capture: :all_but_first)
      |> List.flatten()

    assert files != []

    for file <- files do
      response = conn(:get, "/preview-fonts/files/" <> file) |> OlisUI.Preview.Router.call([])
      assert response.status == 200
      assert get_resp_header(response, "content-type") |> hd() =~ "font/woff2"
    end

    assert (conn(:get, "/preview-fonts/files/unknown.woff2")
            |> OlisUI.Preview.Router.call([])).status == 404
  end
end
