defmodule OlisUI.ComponentImportTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  defmodule Example do
    use Phoenix.Component
    import OlisUI.Button, only: [button: 1]
    import OlisUI.Forms, only: [text_field: 1]

    def render(assigns) do
      ~H"""
      <.button>Save</.button>
      <.text_field id="email" label="Email" />
      """
    end
  end

  test "components can be imported individually" do
    html = render_component(&Example.render/1, %{})

    assert html =~ "Save"
    assert html =~ ~s(id="email")
  end
end
