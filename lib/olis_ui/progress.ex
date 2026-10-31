defmodule OlisUI.Progress do
  @moduledoc "Progress bars, circles, and meters."
  use Phoenix.Component, global_prefixes: ~w(x-)
  import OlisUI.Shared

  @doc "A progress bar. Pass `indeterminate` for ongoing work with no known completion value."
  attr(:value, :any, default: 0)
  attr(:min, :any, default: 0)
  attr(:max, :any, default: 100)
  attr(:label, :string, default: nil)
  attr(:"aria-label", :string, default: nil)
  attr(:"data-slot", :string, default: "progress-bar")
  attr(:value_text, :string, default: nil)
  attr(:show_value, :boolean, default: true)
  attr(:indeterminate, :boolean, default: false)
  attr(:size, :string, default: "md", values: ~w(sm md lg))
  attr(:color, :string, default: "accent", values: ~w(default accent success warning danger))
  attr(:class, :any, default: nil)
  attr(:rest, :global)

  def progress_bar(assigns) do
    value = if assigns.indeterminate, do: nil, else: assigns.value

    assigns =
      assigns
      |> assign(:current_value, value)
      |> assign(:percent, range_percent(value, assigns.min, assigns.max))

    ~H"""
    <div
      class={[
        "progress-bar progress-bar--#{@size} progress-bar--#{@color} grid w-full grid-cols-[1fr_auto] gap-1 [grid-template-areas:'label_output'_'track_track'] disabled:status-disabled data-[disabled=true]:status-disabled aria-disabled:status-disabled",
        @class
      ]}
      data-slot={assigns[:"data-slot"]}
      role="progressbar"
      aria-label={assigns[:"aria-label"] || @label}
      aria-valuemin={@min}
      aria-valuemax={@max}
      aria-valuenow={@current_value}
      aria-valuetext={if !is_nil(@percent), do: @value_text || "#{round(@percent)}%"}
      {@rest}
    >
      <span
        :if={@label}
        class={[label_classes(), "w-fit text-sm font-medium [grid-area:label]"]}
        data-slot="label"
      >{@label}</span><span
        :if={@show_value && !is_nil(@percent)}
        class="progress-bar__output text-sm font-medium tabular-nums [grid-area:output]"
        data-slot="progress-bar-output"
      >{@value_text || "#{round(@percent)}%"}</span>
      <div
        class={[
          "progress-bar__track relative overflow-hidden bg-default [grid-area:track]",
          @size == "sm" && "h-1 rounded-xs",
          @size == "md" && "h-2 rounded-sm",
          @size == "lg" && "h-3 rounded-md"
        ]}
        data-slot="progress-bar-track"
      >
        <div
          class={[
            "progress-bar__fill olis-progress-fill",
            progress_fill_color(@color),
            @size == "sm" && "rounded-xs",
            @size == "md" && "rounded-sm",
            @size == "lg" && "rounded-md",
            is_nil(@current_value) && "w-2/5 animate-progress-bar-indeterminate"
          ]}
          data-slot="progress-bar-fill"
          style={if !is_nil(@percent), do: "width: #{@percent}%"}
        >
        </div>
      </div>
    </div>
    """
  end

  @doc "A circular progress indicator. Pass `indeterminate` when progress is unknown."
  attr(:value, :any, default: 0)
  attr(:min, :any, default: 0)
  attr(:max, :any, default: 100)
  attr(:label, :string, default: nil)
  attr(:"aria-label", :string, default: nil)
  attr(:"data-slot", :string, default: "progress-circle")
  attr(:show_label, :boolean, default: false)
  attr(:value_text, :string, default: nil)
  attr(:indeterminate, :boolean, default: false)
  attr(:size, :string, default: "md", values: ~w(sm md lg))
  attr(:color, :string, default: "accent", values: ~w(default accent success warning danger))
  attr(:class, :any, default: nil)
  attr(:rest, :global)

  def progress_circle(assigns) do
    value = if assigns.indeterminate, do: nil, else: assigns.value
    percent = range_percent(value, assigns.min, assigns.max)
    circumference = 2 * :math.pi() * 16

    offset =
      if is_nil(percent), do: circumference * 0.75, else: circumference * (1 - percent / 100)

    assigns =
      assigns
      |> assign(
        circumference: circumference,
        offset: offset,
        current_value: value,
        percent: percent
      )

    ~H"""
    <div
      class={[
        "progress-circle inline-flex items-center justify-center disabled:status-disabled data-[disabled=true]:status-disabled aria-disabled:status-disabled",
        "progress-circle--#{@size}",
        "progress-circle--#{@color}",
        @class
      ]}
      data-slot={assigns[:"data-slot"]}
      role="progressbar"
      aria-label={assigns[:"aria-label"] || @label}
      aria-valuemin={@min}
      aria-valuemax={@max}
      aria-valuenow={@current_value}
      aria-valuetext={if !is_nil(@percent), do: @value_text || "#{round(@percent)}%"}
      {@rest}
    >
      <svg
        class={[
          "progress-circle__track",
          @size == "sm" && "size-5",
          @size == "md" && "size-7",
          @size == "lg" && "size-9",
          is_nil(@current_value) && "animate-spin"
        ]}
        data-slot="progress-circle-track"
        viewBox="0 0 36 36"
        fill="none"
        aria-hidden="true"
      >
        <circle
          class="progress-circle__track-circle stroke-default"
          data-slot="progress-circle-track-circle"
          cx="18"
          cy="18"
          r="16"
          stroke-width="4"
        />
        <circle
          class={[
            "progress-circle__fill-circle transition-[stroke-dashoffset] duration-300 ease-(--ease-out)",
            progress_stroke_color(@color)
          ]}
          data-slot="progress-circle-fill-circle"
          cx="18"
          cy="18"
          r="16"
          stroke-width="4"
          stroke-linecap="round"
          stroke-dasharray={@circumference}
          stroke-dashoffset={@offset}
          transform="rotate(-90 18 18)"
        />
      </svg>
      <span :if={@show_label && @label} data-slot="label" class="ms-3">{@label}</span>
    </div>
    """
  end

  @doc "A labelled measurement within a known range."
  attr(:value, :any, default: 0)
  attr(:min, :any, default: 0)
  attr(:max, :any, default: 100)
  attr(:label, :string, default: nil)
  attr(:"aria-label", :string, default: nil)
  attr(:"data-slot", :string, default: "meter")
  attr(:value_text, :string, default: nil)
  attr(:show_value, :boolean, default: true)
  attr(:size, :string, default: "md", values: ~w(sm md lg))
  attr(:color, :string, default: "accent", values: ~w(default accent success warning danger))
  attr(:class, :any, default: nil)
  attr(:rest, :global)

  def meter(assigns) do
    assigns =
      assigns
      |> assign(:percent, range_percent(assigns.value, assigns.min, assigns.max))

    ~H"""
    <div
      class={[
        "meter meter--#{@size} meter--#{@color} grid w-full grid-cols-[1fr_auto] gap-1 [grid-template-areas:'label_output'_'track_track'] disabled:status-disabled data-[disabled=true]:status-disabled aria-disabled:status-disabled",
        @class
      ]}
      data-slot={assigns[:"data-slot"]}
      role="meter"
      aria-label={assigns[:"aria-label"] || @label}
      aria-valuemin={@min}
      aria-valuemax={@max}
      aria-valuenow={@value}
      aria-valuetext={@value_text || "#{round(@percent)}%"}
      {@rest}
    >
      <span
        :if={@label}
        class={[label_classes(), "w-fit text-sm font-medium [grid-area:label]"]}
        data-slot="label"
      >{@label}</span><span
        :if={@show_value}
        class="meter__output text-sm font-medium tabular-nums [grid-area:output]"
        data-slot="meter-output"
      >{@value_text ||
        "#{round(@percent)}%"}</span>
      <div
        class={[
          "meter__track relative overflow-hidden bg-default [grid-area:track]",
          @size == "sm" && "h-1 rounded-xs",
          @size == "md" && "h-2 rounded-sm",
          @size == "lg" && "h-3 rounded-md"
        ]}
        data-slot="meter-track"
      >
        <div
          class={[
            "meter__fill olis-progress-fill",
            progress_fill_color(@color),
            @size == "sm" && "rounded-xs",
            @size == "md" && "rounded-sm",
            @size == "lg" && "rounded-md"
          ]}
          data-slot="meter-fill"
          style={"width: #{@percent}%"}
        >
        </div>
      </div>
    </div>
    """
  end

  defp progress_fill_color(color) do
    %{
      "default" => "bg-default-foreground",
      "accent" => "bg-accent",
      "success" => "bg-success",
      "warning" => "bg-warning",
      "danger" => "bg-danger"
    }[color]
  end

  defp progress_stroke_color(color) do
    %{
      "default" => "stroke-default-foreground",
      "accent" => "stroke-accent",
      "success" => "stroke-success",
      "warning" => "stroke-warning",
      "danger" => "stroke-danger"
    }[color]
  end
end
