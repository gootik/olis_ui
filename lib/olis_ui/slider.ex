defmodule OlisUI.Slider do
  @moduledoc "Single-value and range sliders."
  use Phoenix.Component, global_prefixes: ~w(x-)
  import OlisUI.Shared

  @doc "A single-value or multi-thumb slider. Requires OlisUI's Alpine components for pointer interaction and live updates."
  attr(:id, :string, required: true)
  attr(:name, :string, default: nil)
  attr(:label, :string, required: true)
  attr(:value, :any, required: true)
  attr(:min, :any, default: 0)
  attr(:max, :any, default: 100)
  attr(:step, :any, default: 1)
  attr(:orientation, :string, default: "horizontal", values: ~w(horizontal vertical))
  attr(:show_steps, :boolean, default: false)
  attr(:marks, :list, default: [])
  attr(:disabled, :boolean, default: false)
  attr(:class, :any, default: nil)
  attr(:rest, :global, include: ~w(form required))

  def slider(assigns) do
    values = if is_list(assigns.value), do: assigns.value, else: [assigns.value]

    percentages = Enum.map(values, &range_percent(&1, assigns.min, assigns.max))
    first = hd(percentages)
    last = List.last(percentages)
    start = if length(values) == 1, do: 0, else: first
    step_count = (assigns.max - assigns.min) / assigns.step
    nearest_step_count = round(step_count)

    count =
      if abs(step_count - nearest_step_count) <= 1.0e-12 * max(1, abs(step_count)),
        do: nearest_step_count + 1,
        else: floor(step_count) + 1

    steps =
      if assigns.show_steps and count <= 1000 do
        for index <- 0..(count - 1), do: min(assigns.max, assigns.min + index * assigns.step)
      else
        []
      end

    marks =
      Enum.flat_map(assigns.marks, fn mark ->
        {value, label} = if is_tuple(mark), do: mark, else: {mark, mark}

        if is_number(value) and value >= assigns.min and value <= assigns.max,
          do: [{value, label}],
          else: []
      end)

    assigns =
      assign(assigns,
        values: values,
        percentages: percentages,
        start: start,
        finish: last,
        steps: steps,
        visible_marks: marks,
        multiple: is_list(assigns.value)
      )

    ~H"""
    <div
      class={[
        "slider grid disabled:status-disabled data-[disabled=true]:status-disabled aria-disabled:status-disabled [&[data-disabled=true]_[data-slot=label]]:opacity-100",
        @orientation == "horizontal" && "w-full flex-col gap-1 grid-cols-[1fr_auto]",
        @orientation == "horizontal" && @visible_marks == [] &&
          "[grid-template-areas:'label_output'_'track_track']",
        @orientation == "horizontal" && @visible_marks != [] &&
          "[grid-template-areas:'label_output'_'track_track'_'marks_marks']",
        @orientation == "vertical" && "h-full w-fit flex-row gap-2 grid-rows-[auto_1fr_auto]",
        @orientation == "vertical" && @visible_marks == [] &&
          "grid-cols-1 [grid-template-areas:'output'_'track'_'label']",
        @orientation == "vertical" && @visible_marks != [] &&
          "grid-cols-[auto_auto] justify-center [grid-template-areas:'output_output'_'track_marks'_'label_label']",
        @class
      ]}
      data-orientation={@orientation}
      data-disabled={if @disabled, do: "true"}
      data-olis-slider
      x-data="olisSlider"
      x-on:input.capture="input($event)"
      x-on:pointerdown="start($event)"
      x-on:pointermove="move($event)"
      x-on:pointerup="end($event)"
      x-on:pointercancel="end($event)"
      x-on:reset.document="reset($event)"
      x-on:phx:update.document="sync()"
    >
      <label
        for={if @multiple, do: "#{@id}-0", else: @id}
        data-slot="label"
        class={[
          "w-fit text-sm font-medium [grid-area:label]",
          @orientation == "vertical" && "text-center"
        ]}
      >{@label}</label>
      <output
        class={[
          "slider__output text-sm font-medium tabular-nums [grid-area:output]",
          @orientation == "vertical" && "text-center"
        ]}
        data-olis-slider-output
      >{Enum.join(@values, " – ")}</output>
      <div
        class={[
          "slider__track relative touch-none rounded-xl bg-default [grid-area:track]",
          @orientation == "horizontal" &&
            "h-5 w-full border-x-[0.75rem] border-x-transparent data-[fill-start=true]:border-s-accent data-[fill-end=true]:border-e-accent",
          @orientation == "vertical" &&
            "h-full w-5 justify-self-center border-y-[0.75rem] border-y-transparent data-[fill-start=true]:border-b-accent data-[fill-end=true]:border-t-accent"
        ]}
        data-olis-slider-track
        data-fill-start={to_string(@start == 0)}
        data-fill-end={to_string(@finish == 100)}
      >
        <div
          class={[
            "slider__fill pointer-events-none absolute bg-accent",
            @orientation == "horizontal" && "h-full",
            @orientation == "vertical" && "w-full"
          ]}
          data-olis-slider-fill
          style={slider_fill_style(@orientation, @start, @finish)}
        >
        </div>
        <div
          :if={@steps != []}
          class="slider__steps pointer-events-none absolute inset-0 z-1"
          data-slot="slider-steps"
          aria-hidden="true"
        >
          <span
            :for={value <- @steps}
            class={[
              "slider__step olis-slider-point",
              @orientation == "horizontal" &&
                "top-1/2 -translate-x-1/2 -translate-y-1/2 [.slider__steps[data-direction=rtl]_&]:translate-x-1/2",
              @orientation == "vertical" && "left-1/2 -translate-x-1/2 translate-y-1/2"
            ]}
            data-slot="slider-step"
            data-value={value}
            data-filled={
              to_string(
                value >= if(@multiple, do: hd(@values), else: @min) and value <= List.last(@values)
              )
            }
            style={slider_position_style(@orientation, range_percent(value, @min, @max))}
          ></span>
        </div>
        <div
          :for={{value, index} <- Enum.with_index(@values)}
          class="pointer-events-none absolute inset-0"
        >
          <input
            id={if @multiple, do: "#{@id}-#{index}", else: @id}
            name={if @name && @multiple, do: "#{@name}[]", else: @name}
            type="range"
            value={value}
            min={@min}
            max={@max}
            step={@step}
            disabled={@disabled}
            aria-label={if @multiple, do: "#{@label} #{index + 1}", else: @label}
            aria-orientation={@orientation}
            class="peer sr-only"
            data-olis-slider-input
            {@rest}
          />
          <span
            class={[
              "slider__thumb olis-slider-handle",
              @orientation == "horizontal" && "top-1/2",
              @orientation == "vertical" && "left-1/2",
              if(@orientation == "vertical",
                do: "-translate-x-1/2 translate-y-1/2",
                else: "-translate-x-1/2 -translate-y-1/2 rtl:translate-x-1/2"
              )
            ]}
            data-olis-slider-thumb
            data-disabled={if @disabled, do: "true"}
            style={slider_position_style(@orientation, Enum.at(@percentages, index))}
          ></span>
        </div>
      </div>
      <div
        :if={@visible_marks != []}
        class="slider__marks olis-slider-marks"
        data-slot="slider-marks"
      >
        <span
          :for={{value, label} <- @visible_marks}
          class="slider__mark olis-slider-label"
          data-slot="slider-mark"
          data-value={value}
          data-filled={
            to_string(
              value >= if(@multiple, do: hd(@values), else: @min) and value <= List.last(@values)
            )
          }
          style={"--olis-slider-mark-position: #{range_percent(value, @min, @max)}%"}
        ><span>{label}</span></span>
      </div>
    </div>
    """
  end

  defp slider_position_style("vertical", percent), do: "bottom: #{percent}%"
  defp slider_position_style(_, percent), do: "inset-inline-start: #{percent}%"

  defp slider_fill_style("vertical", start, finish),
    do: "bottom: #{start}%; height: #{finish - start}%"

  defp slider_fill_style(_, start, finish),
    do: "inset-inline-start: #{start}%; width: #{finish - start}%"
end
