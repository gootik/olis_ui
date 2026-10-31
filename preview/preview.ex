defmodule OlisUI.Preview do
  @moduledoc false
  use Phoenix.Component
  import OlisUI.Button
  import OlisUI.Checks
  import OlisUI.Controls
  import OlisUI.Display
  import OlisUI.Feedback
  import OlisUI.Forms
  import OlisUI.Progress
  import OlisUI.Table
  import OlisUI.Typography

  def page(assigns) do
    ~H"""
    <!DOCTYPE html>
    <html lang="en" class="scroll-smooth">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <title>OlisUI for LiveView — Component preview</title>
        <link rel="stylesheet" href="/olis_ui.css" />
        <link rel="stylesheet" href="/preview-fonts/index.css" />
        <script>
          try { document.documentElement.dataset.theme = localStorage.getItem('preview-theme') || 'light'; } catch (_) {}
        </script>
      </head>
      <body class="preview-body m-0 bg-[#fafafa] font-preview text-sm text-[#111315] dark:bg-[#08090a] dark:text-white">
        <header class="topbar sticky top-0 z-30 flex h-16 items-center justify-between border-b border-[#e5e7eb] bg-[#fafafa] px-6 dark:border-[#23252a] dark:bg-[#08090a] sm:px-10">
          <a
            class="brand flex items-center gap-2 text-base font-[510] tracking-[-.01em] text-[#111315] no-underline dark:text-white [&>span:last-child]:font-normal [&>span:last-child]:text-[#62666d] dark:[&>span:last-child]:text-[#8a8f98]"
            href="#top"
          ><span class="brand-mark grid size-7 place-items-center rounded-md bg-[#111315] text-base text-white dark:bg-white dark:text-[#08090a]">✳&#xFE0E;</span>
          OlisUI <span>for LiveView</span></a>
          <div class="top-actions flex items-center gap-6">
            <span class="version text-[11px] font-[510] tracking-[.08em] text-[#62666d] dark:text-[#8a8f98] max-[520px]:hidden">EARLY PREVIEW</span><button
              class="theme-toggle grid size-8 cursor-pointer place-items-center rounded-md border border-[#d8dadd] bg-transparent text-base text-[#111315] hover:bg-[#e9eaec] dark:border-[#23252a] dark:text-[#d0d6e0] dark:hover:bg-[#161718]"
              type="button"
              id="theme-toggle"
              aria-label="Toggle color theme"
            >◐</button>
          </div>
        </header>
        <div
          class="layout mx-auto max-w-[1200px]"
          id="top"
        >
          <nav
            aria-label="Component navigation"
            class="navigation sticky top-16 z-20 flex items-center gap-1 overflow-x-auto border-b border-[#e5e7eb] bg-[#fafafa] px-6 py-2 dark:border-[#23252a] dark:bg-[#08090a] sm:px-10 [&>a]:shrink-0 [&>a]:rounded-md [&>a]:px-3 [&>a]:py-2 [&>a]:text-[13px] [&>a]:text-[#62666d] [&>a]:no-underline hover:[&>a]:text-[#111315] dark:[&>a]:text-[#8a8f98] dark:hover:[&>a]:text-white"
          >
            <a
              class="nav-current bg-[#e9eaec] !text-[#111315] dark:bg-[#161718] dark:!text-white [&>span]:hidden"
              href="#overview"
            >Overview <span>↗</span></a>
            <a href="#buttons">Button</a><a href="#inputs">Input</a><a href="#cards">Card</a><a href="#chips">Chip</a><a href="#controls">Controls</a><a href="#feedback">Feedback</a>
          </nav>
          <main class="min-w-0 px-6 sm:px-10">
            <section
              class="intro scroll-mt-32 border-b border-[#e5e7eb] py-20 dark:border-[#23252a] max-[620px]:py-14 [&>h1]:my-6 [&>h1]:text-[clamp(48px,6vw,72px)] [&>h1]:font-[510] [&>h1]:leading-none [&>h1]:tracking-[-.022em] [&_em]:font-[510] [&_em]:not-italic [&_em]:text-[#8a8f98] [&>p]:max-w-[490px] [&>p]:text-base [&>p]:leading-6 [&>p]:text-[#62666d] dark:[&>p]:text-[#8a8f98]"
              id="overview"
            >
              <div class="eyebrow inline-flex items-center gap-2 text-[11px] font-[510] tracking-[.08em] text-[#62666d] dark:text-[#8a8f98] [&>span]:size-1.5 [&>span]:rounded-full [&>span]:bg-[#8a8f98]">
                <span></span> THE COMPONENT LIBRARY
              </div>
              <h1>Build something<br /><em>beautiful.</em></h1>
              <p>
                A first look at OlisUI components for Phoenix LiveView. Thoughtful defaults, flexible styling, and a little less boilerplate.
              </p>
              <div class="intro-actions mt-8 flex items-center gap-6">
                <a
                  href="#buttons"
                  class="intro-link rounded-md bg-accent px-4 py-2.5 text-sm font-[510] text-accent-foreground no-underline hover:bg-accent-hover [&>span]:ml-5"
                >Explore components <span>↘</span></a><span class="intro-caption text-[10px] font-[510] tracking-[.08em] text-[#8a8f98] max-[520px]:hidden">DESIGNED FOR THE WAY YOU BUILD</span>
              </div>
            </section>
            <div class="section-heading flex items-end justify-between pt-20 pb-9 [&_h2]:mt-3 [&_h2]:text-[32px] [&_h2]:font-[510] [&_h2]:tracking-[-.022em] [&_h2_span]:text-[#8a8f98] [&>p]:m-0 [&>p]:leading-6 [&>p]:text-[#62666d] dark:[&>p]:text-[#8a8f98] max-[520px]:[&>p]:hidden">
              <div>
                <p class="text-[10px] font-[510] tracking-[.1em] text-[#62666d] dark:text-[#8a8f98]">
                  THE BUILDING BLOCKS
                </p><h2>Components <span>✳&#xFE0E;</span></h2>
              </div><p>A growing collection of essentials.<br />Explore the examples below.</p>
            </div>
            <section
              class="showcase mb-16 scroll-mt-32 [&_h3]:mt-2 [&_h3]:mb-1 [&_h3]:text-2xl [&_h3]:font-[510] [&_h3]:tracking-[-.012em] [&_code]:whitespace-nowrap [&_code]:rounded-md [&_code]:bg-[#e9eaec] [&_code]:px-2 [&_code]:py-1.5 [&_code]:text-xs [&_code]:text-[#62666d] dark:[&_code]:bg-[#161718] dark:[&_code]:text-[#8a8f98]"
              id="buttons"
            >
              <div class="showcase-title mb-5 flex items-start justify-between gap-3 max-[520px]:flex-wrap [&_p]:m-0 [&_p]:leading-6 [&_p]:text-[#62666d] dark:[&_p]:text-[#8a8f98]">
                <div>
                  <span class="number text-[10px] font-[510] tracking-[.08em] text-[#62666d] dark:text-[#8a8f98]">01 / ACTION</span><h3>
                    Button
                  </h3><p>
                    Give every action the right amount of emphasis.
                  </p>
                </div><code>&lt;.button&gt;</code>
              </div>
              <div class="demo rounded-xl border border-[#e5e7eb] bg-white p-6 dark:border-[#23252a] dark:bg-[#0f1011]">
                <div class="demo-label mb-5 flex justify-between text-[10px] font-[510] tracking-[.08em] text-[#62666d] dark:text-[#8a8f98] [&>span]:font-normal">
                  VARIANTS <span>7 OPTIONS</span>
                </div><div class="demo-row flex flex-wrap items-center gap-2.5">
                  <.button>Primary</.button><.button variant="secondary">Secondary</.button><.button variant="tertiary">Tertiary</.button><.button variant="outline">Outline</.button><.button variant="ghost">Ghost</.button><.button variant="danger">Danger</.button><.button variant="danger-soft">Danger soft</.button>
                </div><div class="divider my-6 h-px bg-[#e5e7eb] dark:bg-[#23252a]"></div><div class="demo-label mb-5 flex justify-between text-[10px] font-[510] tracking-[.08em] text-[#62666d] dark:text-[#8a8f98] [&>span]:font-normal">
                  SIZES & STATES
                </div><div class="demo-row flex flex-wrap items-center gap-2.5">
                  <.button size="sm">Small</.button><.button>Medium</.button><.button size="lg">Large</.button><.button disabled>Disabled</.button><.button
                    icon_only
                    aria-label="Add"
                  >+</.button>
                </div>
              </div>
            </section>
            <section
              class="showcase mb-16 scroll-mt-32 [&_h3]:mt-2 [&_h3]:mb-1 [&_h3]:text-2xl [&_h3]:font-[510] [&_h3]:tracking-[-.012em] [&_code]:whitespace-nowrap [&_code]:rounded-md [&_code]:bg-[#e9eaec] [&_code]:px-2 [&_code]:py-1.5 [&_code]:text-xs [&_code]:text-[#62666d] dark:[&_code]:bg-[#161718] dark:[&_code]:text-[#8a8f98]"
              id="inputs"
            >
              <div class="showcase-title mb-5 flex items-start justify-between gap-3 max-[520px]:flex-wrap [&_p]:m-0 [&_p]:leading-6 [&_p]:text-[#62666d] dark:[&_p]:text-[#8a8f98]">
                <div>
                  <span class="number text-[10px] font-[510] tracking-[.08em] text-[#62666d] dark:text-[#8a8f98]">02 / INPUT</span><h3>
                    Input & text field
                  </h3><p>
                    Clear, accessible inputs for the details that matter.
                  </p>
                </div><code>&lt;.text_field&gt;</code>
              </div>
              <div class="demo rounded-xl border border-[#e5e7eb] bg-white p-6 dark:border-[#23252a] dark:bg-[#0f1011]">
                <div class="demo-label mb-5 flex justify-between text-[10px] font-[510] tracking-[.08em] text-[#62666d] dark:text-[#8a8f98] [&>span]:font-normal">
                  FORM FIELDS <span>LABELS & FEEDBACK</span>
                </div><div class="fields grid grid-cols-3 gap-[22px] max-[850px]:grid-cols-1">
                  <.text_field
                    id="preview-name"
                    label="Your name"
                    placeholder="Jane Smith"
                    description="This is how we'll address you."
                  /><.text_field
                    id="preview-email"
                    label="Email address"
                    type="email"
                    value="hello@example"
                    errors={["Please enter a valid email address."]}
                  /><.text_field id="preview-disabled" label="Workspace" value="Acme Studio" disabled />
                </div>
              </div>
            </section>
            <div class="two-column grid grid-cols-2 gap-6 max-[700px]:grid-cols-1 max-[700px]:gap-0">
              <section
                class="showcase mb-16 scroll-mt-32 [&_h3]:mt-2 [&_h3]:mb-1 [&_h3]:text-2xl [&_h3]:font-[510] [&_h3]:tracking-[-.012em] [&_code]:whitespace-nowrap [&_code]:rounded-md [&_code]:bg-[#e9eaec] [&_code]:px-2 [&_code]:py-1.5 [&_code]:text-xs [&_code]:text-[#62666d] dark:[&_code]:bg-[#161718] dark:[&_code]:text-[#8a8f98]"
                id="cards"
              >
                <div class="showcase-title mb-5 flex items-start justify-between gap-3 max-[520px]:flex-wrap [&_p]:m-0 [&_p]:leading-6 [&_p]:text-[#62666d] dark:[&_p]:text-[#8a8f98]">
                  <div>
                    <span class="number text-[10px] font-[510] tracking-[.08em] text-[#62666d] dark:text-[#8a8f98]">03 / LAYOUT</span><h3>
                      Card
                    </h3><p>
                      A home for related content.
                    </p>
                  </div><code>&lt;.card&gt;</code>
                </div><div class="demo rounded-xl border border-[#e5e7eb] bg-white p-6 dark:border-[#23252a] dark:bg-[#0f1011]">
                  <.card>
                    <div class="sample-card-top flex items-center justify-between">
                      <span class="sample-icon grid size-9 place-items-center rounded-md bg-surface-secondary text-[21px] text-muted">✳&#xFE0E;</span><.chip
                        color="success"
                        variant="soft"
                      >
                        Active
                      </.chip>
                    </div><h4>Everything in its place.</h4><p>
                      Bring your ideas together in a space that feels just right.
                    </p><.button variant="secondary" size="sm">View project ↗</.button>
                  </.card>
                </div>
              </section>
              <section
                class="showcase mb-16 scroll-mt-32 [&_h3]:mt-2 [&_h3]:mb-1 [&_h3]:text-2xl [&_h3]:font-[510] [&_h3]:tracking-[-.012em] [&_code]:whitespace-nowrap [&_code]:rounded-md [&_code]:bg-[#e9eaec] [&_code]:px-2 [&_code]:py-1.5 [&_code]:text-xs [&_code]:text-[#62666d] dark:[&_code]:bg-[#161718] dark:[&_code]:text-[#8a8f98]"
                id="chips"
              >
                <div class="showcase-title mb-5 flex items-start justify-between gap-3 max-[520px]:flex-wrap [&_p]:m-0 [&_p]:leading-6 [&_p]:text-[#62666d] dark:[&_p]:text-[#8a8f98]">
                  <div>
                    <span class="number text-[10px] font-[510] tracking-[.08em] text-[#62666d] dark:text-[#8a8f98]">04 / DISPLAY</span><h3>
                      Chip
                    </h3><p>
                      Small labels, useful context.
                    </p>
                  </div><code>&lt;.chip&gt;</code>
                </div><div class="demo rounded-xl border border-[#e5e7eb] bg-white p-6 dark:border-[#23252a] dark:bg-[#0f1011] chip-demo min-h-[245px] [&_.demo-row]:pt-5">
                  <div class="demo-label mb-5 flex justify-between text-[10px] font-[510] tracking-[.08em] text-[#62666d] dark:text-[#8a8f98] [&>span]:font-normal">
                    STATUS & CATEGORY
                  </div><div class="demo-row flex flex-wrap items-center gap-2.5">
                    <.chip>Default</.chip><.chip color="accent" variant="soft">In progress</.chip><.chip
                      color="success"
                      variant="soft"
                    >
                      Success
                    </.chip><.chip color="warning" variant="soft">Pending</.chip><.chip
                      color="danger"
                      variant="soft"
                    >
                      Attention
                    </.chip>
                  </div>
                </div>
              </section>
            </div>
            <section
              class="showcase mb-16 scroll-mt-32 [&_h3]:mt-2 [&_h3]:mb-1 [&_h3]:text-2xl [&_h3]:font-[510] [&_h3]:tracking-[-.012em] [&_code]:whitespace-nowrap [&_code]:rounded-md [&_code]:bg-[#e9eaec] [&_code]:px-2 [&_code]:py-1.5 [&_code]:text-xs [&_code]:text-[#62666d] dark:[&_code]:bg-[#161718] dark:[&_code]:text-[#8a8f98]"
              id="controls"
            >
              <div class="showcase-title mb-5 flex items-start justify-between gap-3 max-[520px]:flex-wrap [&_p]:m-0 [&_p]:leading-6 [&_p]:text-[#62666d] dark:[&_p]:text-[#8a8f98]">
                <div>
                  <span class="number text-[10px] font-[510] tracking-[.08em] text-[#62666d] dark:text-[#8a8f98]">05 / INPUT</span><h3>
                    Checkbox & switch
                  </h3><p>
                    Native controls with clear selected and disabled states.
                  </p>
                </div><code>&lt;.checkbox&gt;</code>
              </div>
              <div class="demo rounded-xl border border-[#e5e7eb] bg-white p-6 dark:border-[#23252a] dark:bg-[#0f1011]">
                <div class="demo-row flex flex-wrap items-center gap-2.5">
                  <.checkbox id="check-one" checked>Selected</.checkbox><.checkbox id="check-two">
                    Unselected
                  </.checkbox><.checkbox id="check-three" disabled>Disabled</.checkbox><.switch
                    id="switch-one"
                    checked
                  >
                    Notifications
                  </.switch><.switch id="switch-two">Airplane mode</.switch>
                </div>
              </div>
            </section>
            <section
              class="showcase mb-16 scroll-mt-32 [&_h3]:mt-2 [&_h3]:mb-1 [&_h3]:text-2xl [&_h3]:font-[510] [&_h3]:tracking-[-.012em] [&_code]:whitespace-nowrap [&_code]:rounded-md [&_code]:bg-[#e9eaec] [&_code]:px-2 [&_code]:py-1.5 [&_code]:text-xs [&_code]:text-[#62666d] dark:[&_code]:bg-[#161718] dark:[&_code]:text-[#8a8f98]"
              id="feedback"
            >
              <div class="showcase-title mb-5 flex items-start justify-between gap-3 max-[520px]:flex-wrap [&_p]:m-0 [&_p]:leading-6 [&_p]:text-[#62666d] dark:[&_p]:text-[#8a8f98]">
                <div>
                  <span class="number text-[10px] font-[510] tracking-[.08em] text-[#62666d] dark:text-[#8a8f98]">06 / FEEDBACK</span><h3>
                    Feedback & identity
                  </h3><p>
                    Progress, loading, separators, and avatars.
                  </p>
                </div><code>&lt;.progress_bar&gt;</code>
              </div>
              <div class="demo rounded-xl border border-[#e5e7eb] bg-white p-6 dark:border-[#23252a] dark:bg-[#0f1011]">
                <div class="demo-row flex flex-wrap items-center gap-2.5">
                  <.avatar name="Jane Doe" size="sm" /><.avatar name="Alex Kim" /><.avatar
                    name="Morgan Lee"
                    size="lg"
                  /><.spinner size="sm" /><.spinner /><.spinner size="lg" />
                </div><div class="divider my-6 h-px bg-[#e5e7eb] dark:bg-[#23252a]"></div><.progress_bar
                  label="Uploading"
                  value={65}
                /><div class="divider my-6 h-px bg-[#e5e7eb] dark:bg-[#23252a]"></div>
                <div class="demo-row flex flex-wrap items-center gap-2.5">
                  <.progress_circle label="Uploading" value={65} size="sm" /><.progress_circle
                    label="Uploading"
                    value={65}
                  /><.progress_circle label="Uploading" value={65} size="lg" color="success" /><.progress_circle label="Loading" />
                </div>
                <div class="divider my-6 h-px bg-[#e5e7eb] dark:bg-[#23252a]"></div><.meter
                  label="Storage"
                  value={42}
                  max={100}
                  value_text="42 GB of 100 GB"
                /><div class="divider my-6 h-px bg-[#e5e7eb] dark:bg-[#23252a]"></div><.skeleton class="h-4 w-[70%]" /><div class="h-3">
                </div><.skeleton class="h-4 w-[45%]" /><div class="divider my-6 h-px bg-[#e5e7eb] dark:bg-[#23252a]">
                </div><.separator />
              </div>
            </section>
            <section
              class="showcase mb-16 scroll-mt-32 [&_h3]:mt-2 [&_h3]:mb-1 [&_h3]:text-2xl [&_h3]:font-[510] [&_h3]:tracking-[-.012em] [&_code]:whitespace-nowrap [&_code]:rounded-md [&_code]:bg-[#e9eaec] [&_code]:px-2 [&_code]:py-1.5 [&_code]:text-xs [&_code]:text-[#62666d] dark:[&_code]:bg-[#161718] dark:[&_code]:text-[#8a8f98]"
              id="more-components"
            >
              <div class="showcase-title mb-5 flex items-start justify-between gap-3 max-[520px]:flex-wrap [&_p]:m-0 [&_p]:leading-6 [&_p]:text-[#62666d] dark:[&_p]:text-[#8a8f98]">
                <div>
                  <span class="number text-[10px] font-[510] tracking-[.08em] text-[#62666d] dark:text-[#8a8f98]">07 / MORE PRIMITIVES</span><h3>
                    More essentials
                  </h3><p>
                    Native inputs and useful building blocks.
                  </p>
                </div><code>&lt;.radio&gt;</code>
              </div>
              <div class="demo rounded-xl border border-[#e5e7eb] bg-white p-6 dark:border-[#23252a] dark:bg-[#0f1011]">
                <div class="demo-row flex flex-wrap items-center gap-2.5">
                  <.radio id="radio-one" name="plan" value="starter" checked>Starter</.radio><.radio
                    id="radio-two"
                    name="plan"
                    value="pro"
                  >
                    Pro
                  </.radio><.kbd>⌘ K</.kbd><.ui_link href="#top">Back to top</.ui_link>
                </div><div class="divider my-6 h-px bg-[#e5e7eb] dark:bg-[#23252a]"></div><label
                  for="preview-notes"
                  class="olis-label text-sm font-medium"
                >Notes</label><.textarea
                  id="preview-notes"
                  placeholder="Add a note…"
                  rows="3"
                />
              </div>
            </section>
            <section
              class="showcase mb-16 scroll-mt-32 [&_h3]:mt-2 [&_h3]:mb-1 [&_h3]:text-2xl [&_h3]:font-[510] [&_h3]:tracking-[-.012em] [&_code]:whitespace-nowrap [&_code]:rounded-md [&_code]:bg-[#e9eaec] [&_code]:px-2 [&_code]:py-1.5 [&_code]:text-xs [&_code]:text-[#62666d] dark:[&_code]:bg-[#161718] dark:[&_code]:text-[#8a8f98]"
              id="more-patterns"
            >
              <div class="showcase-title mb-5 flex items-start justify-between gap-3 max-[520px]:flex-wrap [&_p]:m-0 [&_p]:leading-6 [&_p]:text-[#62666d] dark:[&_p]:text-[#8a8f98]">
                <div>
                  <span class="number text-[10px] font-[510] tracking-[.08em] text-[#62666d] dark:text-[#8a8f98]">08 / PATTERNS</span><h3>
                    More components
                  </h3><p>
                    Selection, feedback, disclosure, and structured data.
                  </p>
                </div>
              </div>
              <div class="demo rounded-xl border border-[#e5e7eb] bg-white p-6 dark:border-[#23252a] dark:bg-[#0f1011]">
                <label for="preview-select" class="olis-label text-sm font-medium">Plan</label><select id="preview-select"><option>
                  Starter
                </option><option selected>Pro</option></select>
                <div class="divider my-6 h-px bg-[#e5e7eb] dark:bg-[#23252a]"></div><.alert
                  title="Your changes are saved"
                  status="success"
                >
                  Your workspace is up to date.
                </.alert>
                <div class="divider my-6 h-px bg-[#e5e7eb] dark:bg-[#23252a]"></div><details>
                  <summary>What is included?</summary>All the essentials to get started.
                </details>
                <details>
                  <summary>Can I change my plan?</summary>You can update your plan at any time.
                </details>
                <div class="divider my-6 h-px bg-[#e5e7eb] dark:bg-[#23252a]"></div><.data_table
                  label="Team members"
                  rows={[
                    %{name: "Alex Kim", role: "Designer"},
                    %{name: "Jane Smith", role: "Developer"}
                  ]}
                >
                  <:col :let={row} label="Name">{row.name}</:col><:col :let={row} label="Role">
                    {row.role}
                  </:col><:col :let={_row} label="Status">
                    <.badge color="success" size="sm">Active</.badge>
                  </:col>
                </.data_table>
              </div>
            </section>
            <section
              class="showcase mb-16 scroll-mt-32 [&_h3]:mt-2 [&_h3]:mb-1 [&_h3]:text-2xl [&_h3]:font-[510] [&_h3]:tracking-[-.012em] [&_code]:whitespace-nowrap [&_code]:rounded-md [&_code]:bg-[#e9eaec] [&_code]:px-2 [&_code]:py-1.5 [&_code]:text-xs [&_code]:text-[#62666d] dark:[&_code]:bg-[#161718] dark:[&_code]:text-[#8a8f98]"
              id="dialogs"
            >
              <div class="showcase-title mb-5 flex items-start justify-between gap-3 max-[520px]:flex-wrap [&_p]:m-0 [&_p]:leading-6 [&_p]:text-[#62666d] dark:[&_p]:text-[#8a8f98]">
                <div>
                  <span class="number text-[10px] font-[510] tracking-[.08em] text-[#62666d] dark:text-[#8a8f98]">09 / OVERLAY</span><h3>
                    Modal
                  </h3><p>
                    A focused space for a short task or message.
                  </p>
                </div><code>&lt;.modal&gt;</code>
              </div>
              <div class="demo rounded-xl border border-[#e5e7eb] bg-white p-6 dark:border-[#23252a] dark:bg-[#0f1011]">
                <.ui_link href="/live-preview#overlays">Try the interactive modal in the LiveView preview</.ui_link>
              </div>
            </section>
            <footer class="flex justify-between gap-[15px] border-t border-[#e5e7eb] pt-7 pb-10 text-[11px] text-[#62666d] dark:border-[#23252a] dark:text-[#8a8f98] [&>span:first-child]:font-[510] [&>span:first-child]:text-[#111315] dark:[&>span:first-child]:text-white [&>span:nth-child(2)]:text-[9px] [&>span:nth-child(2)]:tracking-[.08em] max-[520px]:[&>span:nth-child(2)]:hidden">
              <span>✳&#xFE0E; &nbsp; OlisUI for LiveView</span><span>AN EARLY LOOK · MADE WITH PHOENIX</span><a href="#top">Back to top ↑</a>
            </footer>
          </main>
        </div>
        <script type="module">
          import { registerOlisUIAlpine } from "/olis_ui_alpine.js";
          import Alpine from "/alpine.esm.js";
          import collapse from "/alpine-collapse.esm.js";
          window.Alpine = Alpine;
          Alpine.plugin(collapse);
          registerOlisUIAlpine(Alpine);
          Alpine.start();
        </script>
        <script>
          document.getElementById('theme-toggle').addEventListener('click', function () {
            var theme = document.documentElement.dataset.theme === 'dark' ? 'light' : 'dark';
            document.documentElement.dataset.theme = theme;
            try { localStorage.setItem('preview-theme', theme); } catch (_) {}
          });
        </script>
      </body>
    </html>
    """
  end
end

defmodule OlisUI.Preview.Router do
  use Plug.Router
  plug(:match)
  plug(:dispatch)

  get "/" do
    html = OlisUI.Preview.page(%{}) |> Phoenix.HTML.Safe.to_iodata()
    conn |> put_resp_content_type("text/html") |> send_resp(200, html)
  end

  get "/olis_ui.css" do
    conn
    |> put_resp_content_type("text/css")
    |> put_resp_header("cache-control", "no-store")
    |> send_resp(200, File.read!(Application.app_dir(:olis_ui, "priv/static/olis_ui.css")))
  end

  get "/preview-fonts/index.css" do
    conn
    |> put_resp_content_type("text/css")
    |> send_resp(
      200,
      File.read!(
        Path.join([File.cwd!(), "node_modules", "@fontsource-variable", "inter", "index.css"])
      )
    )
  end

  get "/preview-fonts/files/:name" do
    if Regex.match?(
         ~r/\Ainter-(?:cyrillic-ext|cyrillic|greek-ext|greek|vietnamese|latin-ext|latin)-wght-normal\.woff2\z/,
         name
       ) do
      conn
      |> put_resp_content_type("font/woff2")
      |> send_resp(
        200,
        File.read!(
          Path.join([File.cwd!(), "node_modules", "@fontsource-variable", "inter", "files", name])
        )
      )
    else
      send_resp(conn, 404, "Not found")
    end
  end

  get "/avatar-demo.svg" do
    conn
    |> put_resp_content_type("image/svg+xml")
    |> send_resp(
      200,
      ~s(<svg xmlns="http://www.w3.org/2000/svg" width="40" height="40"><rect width="40" height="40" fill="#8a8f98"/></svg>)
    )
  end

  get "/list-box-styles.js" do
    conn
    |> put_resp_content_type("text/javascript")
    |> put_resp_header("cache-control", "no-store")
    |> send_resp(200, File.read!(Path.join([File.cwd!(), "assets", "js", "list-box-styles.js"])))
  end

  # Providers are deliberately served from this fixed directory for unbundled preview imports.
  get "/alpine/:name" do
    path = Path.join([File.cwd!(), "assets", "js", "alpine", name])

    if Regex.match?(~r/\A[a-z0-9_]+\.js\z/, name) do
      case File.read(path) do
        {:ok, contents} ->
          conn
          |> put_resp_content_type("text/javascript")
          |> put_resp_header("cache-control", "no-store")
          |> send_resp(200, contents)

        {:error, _} ->
          send_resp(conn, 404, "Not found")
      end
    else
      send_resp(conn, 404, "Not found")
    end
  end

  get "/olis_ui_alpine.js" do
    conn
    |> put_resp_content_type("text/javascript")
    |> put_resp_header("cache-control", "no-store")
    |> send_resp(200, File.read!(Path.join([File.cwd!(), "assets", "js", "alpine.js"])))
  end

  get "/alpine.esm.js" do
    conn
    |> put_resp_content_type("text/javascript")
    |> send_resp(
      200,
      File.read!(Path.join([File.cwd!(), "node_modules", "alpinejs", "dist", "module.esm.js"]))
    )
  end

  get "/alpine-collapse.esm.js" do
    conn
    |> put_resp_content_type("text/javascript")
    |> send_resp(
      200,
      File.read!(
        Path.join([File.cwd!(), "node_modules", "@alpinejs", "collapse", "dist", "module.esm.js"])
      )
    )
  end

  get "/phoenix.mjs" do
    conn
    |> put_resp_content_type("text/javascript")
    |> send_resp(200, File.read!(Application.app_dir(:phoenix, "priv/static/phoenix.mjs")))
  end

  get "/phoenix_live_view.esm.js" do
    conn
    |> put_resp_content_type("text/javascript")
    |> send_resp(
      200,
      File.read!(Application.app_dir(:phoenix_live_view, "priv/static/phoenix_live_view.esm.js"))
    )
  end

  match(_, do: send_resp(conn, 404, "Not found"))
end

defmodule Mix.Tasks.Preview do
  @moduledoc false
  use Mix.Task
  @shortdoc "Starts the local component preview"
  def run(_) do
    Mix.Task.run("app.start")
    Tailwind.install_and_run(:preview, [])
    port = String.to_integer(System.get_env("PORT", "4000"))

    Application.put_env(:olis_ui, OlisUI.Preview.Endpoint,
      adapter: Bandit.PhoenixAdapter,
      http: [ip: {127, 0, 0, 1}, port: port],
      server: true,
      secret_key_base: String.duplicate("preview-secret-key-", 4),
      live_view: [signing_salt: "livepreview"],
      pubsub_server: OlisUI.Preview.PubSub
    )

    {:ok, _} =
      Phoenix.PubSub.Supervisor.start_link(
        name: OlisUI.Preview.PubSub,
        adapter: Phoenix.PubSub.PG2
      )

    {:ok, _} = OlisUI.Preview.Endpoint.start_link()
    Mix.shell().info("Preview available at http://localhost:#{port}")
    Process.sleep(:infinity)
  end
end
