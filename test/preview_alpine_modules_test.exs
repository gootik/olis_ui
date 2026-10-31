unless Code.ensure_loaded?(HeroUI.Preview.Endpoint),
  do: Code.require_file("../preview/live_preview.ex", __DIR__)

unless Code.ensure_loaded?(HeroUI.Preview.Router),
  do: Code.require_file("../preview/preview.ex", __DIR__)

defmodule HeroUI.PreviewAlpineModulesTest do
  use ExUnit.Case, async: true
  import Plug.Test
  import Plug.Conn, only: [get_resp_header: 2]

  test "the preview serves each Alpine provider and rejects invalid or missing names" do
    directory = Path.join([File.cwd!(), "assets", "js", "alpine"])
    modules = Path.wildcard(Path.join(directory, "*.js"))
    assert modules != []
    index = conn(:get, "/hero_ui_alpine.js") |> HeroUI.Preview.Router.call([])
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
      assert (conn(:get, "/" <> dependency) |> HeroUI.Preview.Router.call([])).status == 200
    end

    for path <- modules do
      response = conn(:get, "/alpine/" <> Path.basename(path)) |> HeroUI.Preview.Router.call([])
      assert response.status == 200
      assert response.resp_body == File.read!(path)
      assert get_resp_header(response, "content-type") |> hd() =~ "text/javascript"

      dependencies =
        Regex.scan(~r/from "\.\.\/([a-z0-9_]+\.js)"/, response.resp_body, capture: :all_but_first)
        |> List.flatten()

      for dependency <- dependencies do
        assert (conn(:get, "/" <> dependency) |> HeroUI.Preview.Router.call([])).status == 200
      end
    end

    for path <- ["/alpine/__missing__.js", "/alpine/invalid.name.js"] do
      assert (conn(:get, path) |> HeroUI.Preview.Router.call([])).status == 404
    end
  end
end
