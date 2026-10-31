defmodule OlisUI.Pagination do
  @moduledoc "Page navigation controls."
  use Phoenix.Component, global_prefixes: ~w(x-)

  @doc """
  Page navigation with bounded page links. Provide either `on_change` for a
  LiveView event receiving `%{"page" => "N"}`, `href` as a one-argument URL
  function, or `patch` as a one-argument LiveView patch URL function. The caller
  owns the current page and data loading. `on_change` also accepts a
  `Phoenix.LiveView.JS` command. Use `show_pages={false}` for previous/next only.
  """
  attr(:page, :integer, required: true)
  attr(:total_pages, :integer, required: true)
  attr(:on_change, :any, default: nil)
  attr(:href, :any, default: nil)
  attr(:patch, :any, default: nil)
  attr(:target, :any, default: nil)
  attr(:siblings, :integer, default: 1)
  attr(:show_pages, :boolean, default: true)
  attr(:show_controls, :boolean, default: true)
  attr(:disabled, :boolean, default: false)
  attr(:page_label, :any, default: nil)
  attr(:label, :string, default: "Pagination")
  attr(:previous_label, :string, default: "Previous")
  attr(:next_label, :string, default: "Next")
  attr(:size, :string, default: "md", values: ~w(sm md lg))
  attr(:class, :any, default: nil)
  attr(:rest, :global)
  slot(:summary)
  slot(:previous_icon)
  slot(:next_icon)

  def pagination(assigns) do
    data_slot =
      Map.get(assigns.rest, :"data-slot") || Map.get(assigns.rest, "data-slot") || "pagination"

    aria_label =
      Map.get(assigns.rest, :"aria-label") || Map.get(assigns.rest, "aria-label") || assigns.label

    rest = Map.drop(assigns.rest, [:"data-slot", "data-slot", :"aria-label", "aria-label"])

    assigns =
      assign(
        assigns,
        :pages,
        pagination_pages(assigns.page, assigns.total_pages, assigns.siblings)
      )
      |> assign(data_slot: data_slot, aria_label: aria_label, rest: rest)

    ~H"""
    <nav
      aria-label={@aria_label}
      class={[
        "pagination flex w-full flex-col items-center justify-between gap-4 sm:flex-row",
        "pagination--#{@size}",
        @class
      ]}
      data-slot={@data_slot}
      {@rest}
    >
      <div
        :if={@summary != []}
        class={[
          "pagination__summary flex items-center gap-2 self-start text-muted sm:self-center",
          @size == "sm" && "text-xs",
          @size == "md" && "text-sm",
          @size == "lg" && "text-base"
        ]}
        data-slot="pagination-summary"
      >
        {render_slot(@summary)}
      </div>
      <ul
        class="pagination__content flex items-center gap-1 self-start sm:self-center"
        data-slot="pagination-content"
      >
        <li :if={@show_controls} class="pagination__item inline-flex">
          <.pagination_control
            size={@size}
            page={max(@page - 1, 1)}
            label={@previous_label}
            disabled={@disabled || @page <= 1 || @total_pages == 0}
            nav
            on_change={@on_change}
            href={@href}
            patch={@patch}
            target={@target}
          >
            <span class="rtl:rotate-180" data-slot="pagination-previous-icon" aria-hidden="true">{render_slot(
              @previous_icon
            )}<OlisUI.Icon.icon
              :if={@previous_icon == []}
              name="chevron-left"
            /></span><span>{@previous_label}</span>
          </.pagination_control>
        </li>
        <li :for={item <- if(@show_pages, do: @pages, else: [])} class="pagination__item inline-flex">
          <span
            :if={item == :ellipsis}
            class={[
              "pagination__ellipsis inline-flex items-center justify-center text-muted select-none",
              @size == "sm" && "size-8 text-xs md:size-7",
              @size == "md" && "size-9 text-sm md:size-8",
              @size == "lg" && "size-10 text-base md:size-9"
            ]}
            aria-hidden="true"
          >…</span>
          <.pagination_control
            :if={item != :ellipsis}
            size={@size}
            page={item}
            label={if @page_label, do: @page_label.(item), else: "Page #{item}"}
            active={item == @page}
            disabled={@disabled}
            on_change={@on_change}
            href={@href}
            patch={@patch}
            target={@target}
          >
            {item}
          </.pagination_control>
        </li>
        <li :if={@show_controls} class="pagination__item inline-flex">
          <.pagination_control
            size={@size}
            page={min(@page + 1, max(@total_pages, 1))}
            label={@next_label}
            disabled={@disabled || @page >= @total_pages}
            nav
            on_change={@on_change}
            href={@href}
            patch={@patch}
            target={@target}
          >
            <span>{@next_label}</span><span
              class="rtl:rotate-180"
              data-slot="pagination-next-icon"
              aria-hidden="true"
            >{render_slot(@next_icon)}<OlisUI.Icon.icon
              :if={@next_icon == []}
              name="chevron-right"
            /></span>
          </.pagination_control>
        </li>
      </ul>
    </nav>
    """
  end

  attr(:page, :integer, required: true)
  attr(:size, :string, required: true)
  attr(:label, :string, required: true)
  attr(:active, :boolean, default: false)
  attr(:disabled, :boolean, default: false)
  attr(:nav, :boolean, default: false)
  attr(:on_change, :any, default: nil)
  attr(:href, :any, default: nil)
  attr(:patch, :any, default: nil)
  attr(:target, :any, default: nil)
  slot(:inner_block, required: true)

  defp pagination_control(assigns) do
    ~H"""
    <span
      :if={(@href || @patch) && @disabled}
      class={[
        "pagination__link pagination__link--#{@size} olis-action",
        @nav && "pagination__link--nav"
      ]}
      aria-disabled="true"
      aria-label={@label}
      aria-current={if @active, do: "page"}
      data-active={if @active, do: "true"}
    >{render_slot(@inner_block)}</span>
    <a
      :if={@href && !@disabled}
      href={@href.(@page)}
      class={[
        "pagination__link pagination__link--#{@size} olis-action",
        @nav && "pagination__link--nav"
      ]}
      aria-label={@label}
      aria-current={if @active, do: "page"}
      data-active={if @active, do: "true"}
    >{render_slot(@inner_block)}</a>
    <Phoenix.Component.link
      :if={@patch && !@disabled}
      patch={@patch.(@page)}
      class={[
        "pagination__link pagination__link--#{@size} olis-action",
        @nav && "pagination__link--nav"
      ]}
      aria-label={@label}
      aria-current={if @active, do: "page"}
      data-active={if @active, do: "true"}
    >{render_slot(@inner_block)}</Phoenix.Component.link>
    <button
      :if={!@href && !@patch}
      type="button"
      class={[
        "pagination__link pagination__link--#{@size} olis-action",
        @nav && "pagination__link--nav"
      ]}
      aria-label={@label}
      aria-current={if @active, do: "page"}
      data-active={if @active, do: "true"}
      disabled={@disabled}
      phx-click={@on_change}
      phx-value-page={@page}
      phx-target={@target}
    >{render_slot(@inner_block)}</button>
    """
  end

  defp pagination_pages(_page, 0, _siblings), do: []

  defp pagination_pages(page, total, siblings) do
    first = max(2, page - siblings)
    last = min(total - 1, page + siblings)
    middle = if first <= last, do: Enum.to_list(first..last), else: []
    numbers = Enum.uniq([1] ++ middle ++ [total]) |> Enum.sort()

    numbers
    |> Enum.reduce([], fn number, acc ->
      case acc do
        [previous | _] when number - previous == 2 -> [number, previous + 1 | acc]
        [previous | _] when number - previous > 2 -> [number, :ellipsis | acc]
        _ -> [number | acc]
      end
    end)
    |> Enum.reverse()
  end
end
