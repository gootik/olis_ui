defmodule OlisUI.Icon do
  @moduledoc "Decorative icons from Gravity UI."
  use Phoenix.Component, global_prefixes: ~w(x-)

  @icon_names ~w(
    arrow-down-to-line arrow-rotate-left arrow-rotate-right arrow-up-right-from-square bold chart-line check chevron-down chevron-left chevron-right chevron-up circle-check circle-exclamation circle-info circle-xmark copy cube gear house italic layout-cells magnifier minus persons plus receipt scissors sun triangle-exclamation underline wallet xmark
  )
  @icons Map.new(@icon_names, fn name ->
           path = Path.expand("../../assets/icons/#{name}.svg", __DIR__)
           @external_resource path
           {name, File.read!(path)}
         end)

  @doc "Renders a decorative Gravity UI icon."
  attr(:name, :string, required: true, values: @icon_names)
  attr(:class, :any, default: nil)
  attr(:rest, :global)

  def icon(assigns) do
    assigns = assign(assigns, :svg, Map.fetch!(@icons, assigns.name))

    ~H"""
    <span class={["inline-flex shrink-0 [&>svg]:size-full", @class]} aria-hidden="true" {@rest}>{Phoenix.HTML.raw(
      @svg
    )}</span>
    """
  end
end
