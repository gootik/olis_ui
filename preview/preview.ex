defmodule HeroUI.Preview do
  use Phoenix.Component
  import HeroUI

  def page(assigns) do
    ~H"""
    <!DOCTYPE html>
    <html lang="en" class="scroll-smooth">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <title>HeroUI for LiveView — Component preview</title>
        <link rel="stylesheet" href="/hero_ui.css" />
        <script>
          try { document.documentElement.dataset.theme = localStorage.getItem('preview-theme') || 'light'; } catch (_) {}
        </script>
      </head>
      <body class="m-0 bg-[#fafaf8] font-sans text-sm text-[#18191a] dark:bg-[#101112] dark:text-[#f1f2ef]">
        <header class="topbar sticky top-0 z-[2] flex h-[72px] items-center justify-between border-b border-[#e9eae7] bg-[#fafaf8] px-[5%] dark:border-[#303230] dark:bg-[#101112] max-[520px]:h-16">
          <a
            class="brand flex items-center gap-[9px] text-base font-[750] tracking-[-.04em] [&>span:last-child]:font-[450] [&>span:last-child]:tracking-normal [&>span:last-child]:text-[#73767a] dark:[&>span:last-child]:text-[#a0a39e]"
            href="#top"
          ><span class="brand-mark grid size-[29px] place-items-center rounded-[9px] bg-[#d9f99d] text-[21px] text-[#111] dark:bg-[#9bbf5c]">✳&#xFE0E;</span>
          HeroUI <span>for LiveView</span></a>
          <div class="top-actions flex items-center gap-[22px]">
            <span class="version text-[10px] font-bold tracking-[.1em] text-[#73767a] dark:text-[#a0a39e] max-[520px]:hidden">EARLY PREVIEW</span><button
              class="theme-toggle size-9 cursor-pointer rounded-full border border-[#e9eae7] bg-white text-[19px] text-[#18191a] dark:border-[#303230] dark:bg-[#1a1b1d] dark:text-[#f1f2ef]"
              type="button"
              id="theme-toggle"
              aria-label="Toggle color theme"
            >◐</button>
          </div>
        </header>
        <div
          class="layout mx-auto grid max-w-[1440px] grid-cols-[230px_minmax(0,1fr)] max-[850px]:block"
          id="top"
        >
          <aside class="sidebar border-r border-[#e9eae7] pt-[52px] pr-[26px] pb-[30px] pl-8 dark:border-[#303230] max-[850px]:hidden [&>a]:flex [&>a]:justify-between [&>a]:rounded-[9px] [&>a]:px-3 [&>a]:py-[11px] [&>a]:text-[#73767a] dark:[&>a]:text-[#a0a39e] hover:[&>a]:bg-[#f3f4f1] hover:[&>a]:font-semibold hover:[&>a]:text-[#18191a] dark:hover:[&>a]:bg-[#222421] dark:hover:[&>a]:text-[#f1f2ef]">
            <p class="nav-label text-[10px] font-bold tracking-[.1em] text-[#73767a] dark:text-[#a0a39e] mb-4 ml-3">
              EXPLORE
            </p>
            <a
              class="nav-current mb-[38px] bg-[#f3f4f1] font-semibold !text-[#18191a] dark:bg-[#222421] dark:!text-[#f1f2ef]"
              href="#overview"
            >Overview <span>↗</span></a>
            <p class="nav-label text-[10px] font-bold tracking-[.1em] text-[#73767a] dark:text-[#a0a39e] mb-4 ml-3">
              COMPONENTS
            </p>
            <a href="#buttons">Button</a><a href="#inputs">Input</a><a href="#cards">Card</a><a href="#chips">Chip</a><a href="#controls">Controls</a><a href="#feedback">Feedback</a>
            <div class="sidebar-note mt-[100px] rounded-[14px] bg-[#f3f4f1] p-[18px] dark:bg-[#222421] [&>span]:mb-3.5 [&>span]:block [&>span]:text-[22px] [&>strong]:text-xs [&>p]:mb-0 [&>p]:text-xs [&>p]:leading-[1.6] [&>p]:text-[#73767a] dark:[&>p]:text-[#a0a39e]">
              <span>✦</span><strong>Built for LiveView</strong><p>
                Familiar components, right in your HEEx templates.
              </p>
            </div>
          </aside>
          <main class="min-w-0 px-[6%]">
            <section
              class="intro border-b border-[#e9eae7] pt-[82px] pb-[74px] dark:border-[#303230] max-[850px]:py-[60px] [&>h1]:my-[25px] [&>h1]:text-[clamp(48px,7vw,82px)] [&>h1]:font-[650] [&>h1]:leading-[1.02] [&>h1]:tracking-[-.065em] max-[520px]:[&>h1]:text-[51px] [&_em]:font-[450] [&_em]:not-italic [&_em]:text-[#999e95] [&>p]:max-w-[490px] [&>p]:text-base [&>p]:leading-[1.75] [&>p]:text-[#73767a] dark:[&>p]:text-[#a0a39e]"
              id="overview"
            >
              <div class="eyebrow inline-flex items-center gap-2 text-[10px] font-[750] tracking-[.12em] [&>span]:size-[7px] [&>span]:rounded-full [&>span]:bg-[#83bd37]">
                <span></span> THE COMPONENT LIBRARY
              </div>
              <h1>Build something<br /><em>beautiful.</em></h1>
              <p>
                A first look at HeroUI-inspired components for Phoenix LiveView. Thoughtful defaults, flexible styling, and a little less boilerplate.
              </p>
              <div class="intro-actions mt-[30px] flex items-center gap-[25px]">
                <a
                  href="#buttons"
                  class="intro-link rounded-[10px] bg-[#18191a] px-[17px] py-3.5 font-semibold text-[#fafaf8] dark:bg-[#f1f2ef] dark:text-[#101112] [&>span]:ml-5"
                >Explore components <span>↘</span></a><span class="intro-caption text-[10px] font-bold tracking-[.1em] text-[#73767a] dark:text-[#a0a39e] text-[9px] max-[520px]:hidden">DESIGNED FOR THE WAY YOU BUILD</span>
              </div>
            </section>
            <div class="section-heading flex items-end justify-between pt-[68px] pb-9 [&_h2]:mt-2.5 [&_h2]:text-4xl [&_h2]:tracking-[-.05em] [&_h2_span]:text-[#98bd66] [&>p]:m-0 [&>p]:leading-[1.6] [&>p]:text-[#73767a] dark:[&>p]:text-[#a0a39e] max-[520px]:[&>p]:hidden">
              <div>
                <p class="text-[10px] font-bold tracking-[.1em] text-[#73767a] dark:text-[#a0a39e]">
                  THE BUILDING BLOCKS
                </p><h2>Components <span>✳&#xFE0E;</span></h2>
              </div><p>A growing collection of essentials.<br />Explore the first five below.</p>
            </div>
            <section
              class="showcase mb-[54px] scroll-mt-[95px] [&_h3]:mt-[9px] [&_h3]:mb-[7px] [&_h3]:text-[23px] [&_h3]:tracking-[-.04em] [&_code]:whitespace-nowrap [&_code]:rounded-md [&_code]:bg-[#f3f4f1] [&_code]:px-[9px] [&_code]:py-[7px] [&_code]:text-[11px] [&_code]:text-[#73767a] dark:[&_code]:bg-[#222421] dark:[&_code]:text-[#a0a39e]"
              id="buttons"
            >
              <div class="showcase-title mb-[18px] flex items-start justify-between gap-3 max-[520px]:flex-wrap [&_p]:m-0 [&_p]:leading-[1.5] [&_p]:text-[#73767a] dark:[&_p]:text-[#a0a39e]">
                <div>
                  <span class="number text-[10px] font-bold tracking-[.1em] text-[#73767a] dark:text-[#a0a39e]">01 / ACTION</span><h3>
                    Button
                  </h3><p>
                    Give every action the right amount of emphasis.
                  </p>
                </div><code>&lt;.button&gt;</code>
              </div>
              <div class="demo rounded-2xl border border-[#e9eae7] bg-white p-[25px] dark:border-[#303230] dark:bg-[#1a1b1d]">
                <div class="demo-label text-[10px] font-bold tracking-[.1em] text-[#73767a] dark:text-[#a0a39e] mb-5 flex justify-between text-[9px] [&>span]:font-medium">
                  VARIANTS <span>7 OPTIONS</span>
                </div><div class="demo-row flex flex-wrap items-center gap-2.5">
                  <.button>Primary</.button><.button variant="secondary">Secondary</.button><.button variant="tertiary">Tertiary</.button><.button variant="outline">Outline</.button><.button variant="ghost">Ghost</.button><.button variant="danger">Danger</.button><.button variant="danger-soft">Danger soft</.button>
                </div><div class="divider my-[27px] h-px bg-[#e9eae7] dark:bg-[#303230]"></div><div class="demo-label text-[10px] font-bold tracking-[.1em] text-[#73767a] dark:text-[#a0a39e] mb-5 flex justify-between text-[9px] [&>span]:font-medium">
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
              class="showcase mb-[54px] scroll-mt-[95px] [&_h3]:mt-[9px] [&_h3]:mb-[7px] [&_h3]:text-[23px] [&_h3]:tracking-[-.04em] [&_code]:whitespace-nowrap [&_code]:rounded-md [&_code]:bg-[#f3f4f1] [&_code]:px-[9px] [&_code]:py-[7px] [&_code]:text-[11px] [&_code]:text-[#73767a] dark:[&_code]:bg-[#222421] dark:[&_code]:text-[#a0a39e]"
              id="inputs"
            >
              <div class="showcase-title mb-[18px] flex items-start justify-between gap-3 max-[520px]:flex-wrap [&_p]:m-0 [&_p]:leading-[1.5] [&_p]:text-[#73767a] dark:[&_p]:text-[#a0a39e]">
                <div>
                  <span class="number text-[10px] font-bold tracking-[.1em] text-[#73767a] dark:text-[#a0a39e]">02 / INPUT</span><h3>
                    Input & text field
                  </h3><p>
                    Clear, accessible inputs for the details that matter.
                  </p>
                </div><code>&lt;.text_field&gt;</code>
              </div>
              <div class="demo rounded-2xl border border-[#e9eae7] bg-white p-[25px] dark:border-[#303230] dark:bg-[#1a1b1d]">
                <div class="demo-label text-[10px] font-bold tracking-[.1em] text-[#73767a] dark:text-[#a0a39e] mb-5 flex justify-between text-[9px] [&>span]:font-medium">
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
            <div class="two-column grid grid-cols-2 gap-[26px] max-[850px]:grid-cols-1 max-[850px]:gap-0">
              <section
                class="showcase mb-[54px] scroll-mt-[95px] [&_h3]:mt-[9px] [&_h3]:mb-[7px] [&_h3]:text-[23px] [&_h3]:tracking-[-.04em] [&_code]:whitespace-nowrap [&_code]:rounded-md [&_code]:bg-[#f3f4f1] [&_code]:px-[9px] [&_code]:py-[7px] [&_code]:text-[11px] [&_code]:text-[#73767a] dark:[&_code]:bg-[#222421] dark:[&_code]:text-[#a0a39e]"
                id="cards"
              >
                <div class="showcase-title mb-[18px] flex items-start justify-between gap-3 max-[520px]:flex-wrap [&_p]:m-0 [&_p]:leading-[1.5] [&_p]:text-[#73767a] dark:[&_p]:text-[#a0a39e]">
                  <div>
                    <span class="number text-[10px] font-bold tracking-[.1em] text-[#73767a] dark:text-[#a0a39e]">03 / LAYOUT</span><h3>
                      Card
                    </h3><p>
                      A home for related content.
                    </p>
                  </div><code>&lt;.card&gt;</code>
                </div><div class="demo rounded-2xl border border-[#e9eae7] bg-white p-[25px] dark:border-[#303230] dark:bg-[#1a1b1d] card-demo min-h-[245px] [&_h4]:mt-[18px] [&_h4]:mb-[7px] [&_h4]:text-base [&_p]:mb-4 [&_p]:text-xs [&_p]:leading-[1.6] [&_p]:text-[#73767a] dark:[&_p]:text-[#a0a39e]">
                  <.card>
                    <div class="sample-card-top flex items-center justify-between">
                      <span class="sample-icon grid size-9 place-items-center rounded-[11px] bg-[#d9f99d] text-[21px] text-[#111] dark:bg-[#9bbf5c]">✳&#xFE0E;</span><.chip
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
                class="showcase mb-[54px] scroll-mt-[95px] [&_h3]:mt-[9px] [&_h3]:mb-[7px] [&_h3]:text-[23px] [&_h3]:tracking-[-.04em] [&_code]:whitespace-nowrap [&_code]:rounded-md [&_code]:bg-[#f3f4f1] [&_code]:px-[9px] [&_code]:py-[7px] [&_code]:text-[11px] [&_code]:text-[#73767a] dark:[&_code]:bg-[#222421] dark:[&_code]:text-[#a0a39e]"
                id="chips"
              >
                <div class="showcase-title mb-[18px] flex items-start justify-between gap-3 max-[520px]:flex-wrap [&_p]:m-0 [&_p]:leading-[1.5] [&_p]:text-[#73767a] dark:[&_p]:text-[#a0a39e]">
                  <div>
                    <span class="number text-[10px] font-bold tracking-[.1em] text-[#73767a] dark:text-[#a0a39e]">04 / DISPLAY</span><h3>
                      Chip
                    </h3><p>
                      Small labels, useful context.
                    </p>
                  </div><code>&lt;.chip&gt;</code>
                </div><div class="demo rounded-2xl border border-[#e9eae7] bg-white p-[25px] dark:border-[#303230] dark:bg-[#1a1b1d] chip-demo min-h-[245px] [&_.demo-row]:pt-5">
                  <div class="demo-label text-[10px] font-bold tracking-[.1em] text-[#73767a] dark:text-[#a0a39e] mb-5 flex justify-between text-[9px] [&>span]:font-medium">
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
              class="showcase mb-[54px] scroll-mt-[95px] [&_h3]:mt-[9px] [&_h3]:mb-[7px] [&_h3]:text-[23px] [&_h3]:tracking-[-.04em] [&_code]:whitespace-nowrap [&_code]:rounded-md [&_code]:bg-[#f3f4f1] [&_code]:px-[9px] [&_code]:py-[7px] [&_code]:text-[11px] [&_code]:text-[#73767a] dark:[&_code]:bg-[#222421] dark:[&_code]:text-[#a0a39e]"
              id="controls"
            >
              <div class="showcase-title mb-[18px] flex items-start justify-between gap-3 max-[520px]:flex-wrap [&_p]:m-0 [&_p]:leading-[1.5] [&_p]:text-[#73767a] dark:[&_p]:text-[#a0a39e]">
                <div>
                  <span class="number text-[10px] font-bold tracking-[.1em] text-[#73767a] dark:text-[#a0a39e]">05 / INPUT</span><h3>
                    Checkbox & switch
                  </h3><p>
                    Native controls with clear selected and disabled states.
                  </p>
                </div><code>&lt;.checkbox&gt;</code>
              </div>
              <div class="demo rounded-2xl border border-[#e9eae7] bg-white p-[25px] dark:border-[#303230] dark:bg-[#1a1b1d]">
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
              class="showcase mb-[54px] scroll-mt-[95px] [&_h3]:mt-[9px] [&_h3]:mb-[7px] [&_h3]:text-[23px] [&_h3]:tracking-[-.04em] [&_code]:whitespace-nowrap [&_code]:rounded-md [&_code]:bg-[#f3f4f1] [&_code]:px-[9px] [&_code]:py-[7px] [&_code]:text-[11px] [&_code]:text-[#73767a] dark:[&_code]:bg-[#222421] dark:[&_code]:text-[#a0a39e]"
              id="feedback"
            >
              <div class="showcase-title mb-[18px] flex items-start justify-between gap-3 max-[520px]:flex-wrap [&_p]:m-0 [&_p]:leading-[1.5] [&_p]:text-[#73767a] dark:[&_p]:text-[#a0a39e]">
                <div>
                  <span class="number text-[10px] font-bold tracking-[.1em] text-[#73767a] dark:text-[#a0a39e]">06 / FEEDBACK</span><h3>
                    Feedback & identity
                  </h3><p>
                    Progress, loading, separators, and avatars.
                  </p>
                </div><code>&lt;.progress_bar&gt;</code>
              </div>
              <div class="demo rounded-2xl border border-[#e9eae7] bg-white p-[25px] dark:border-[#303230] dark:bg-[#1a1b1d]">
                <div class="demo-row flex flex-wrap items-center gap-2.5">
                  <.avatar name="Jane Doe" size="sm" /><.avatar name="Alex Kim" /><.avatar
                    name="Morgan Lee"
                    size="lg"
                  /><.spinner size="sm" /><.spinner /><.spinner size="lg" />
                </div><div class="divider my-[27px] h-px bg-[#e9eae7] dark:bg-[#303230]"></div><.progress_bar
                  label="Uploading"
                  value={65}
                /><div class="divider my-[27px] h-px bg-[#e9eae7] dark:bg-[#303230]"></div>
                <div class="demo-row flex flex-wrap items-center gap-2.5">
                  <.progress_circle label="Uploading" value={65} size="sm" /><.progress_circle
                    label="Uploading"
                    value={65}
                  /><.progress_circle label="Uploading" value={65} size="lg" color="success" /><.progress_circle label="Loading" />
                </div>
                <div class="divider my-[27px] h-px bg-[#e9eae7] dark:bg-[#303230]"></div><.meter
                  label="Storage"
                  value={42}
                  max={100}
                  value_text="42 GB of 100 GB"
                /><div class="divider my-[27px] h-px bg-[#e9eae7] dark:bg-[#303230]"></div><.skeleton class="h-4 w-[70%]" /><div class="h-3">
                </div><.skeleton class="h-4 w-[45%]" /><div class="divider my-[27px] h-px bg-[#e9eae7] dark:bg-[#303230]">
                </div><.separator />
              </div>
            </section>
            <section
              class="showcase mb-[54px] scroll-mt-[95px] [&_h3]:mt-[9px] [&_h3]:mb-[7px] [&_h3]:text-[23px] [&_h3]:tracking-[-.04em] [&_code]:whitespace-nowrap [&_code]:rounded-md [&_code]:bg-[#f3f4f1] [&_code]:px-[9px] [&_code]:py-[7px] [&_code]:text-[11px] [&_code]:text-[#73767a] dark:[&_code]:bg-[#222421] dark:[&_code]:text-[#a0a39e]"
              id="more-components"
            >
              <div class="showcase-title mb-[18px] flex items-start justify-between gap-3 max-[520px]:flex-wrap [&_p]:m-0 [&_p]:leading-[1.5] [&_p]:text-[#73767a] dark:[&_p]:text-[#a0a39e]">
                <div>
                  <span class="number text-[10px] font-bold tracking-[.1em] text-[#73767a] dark:text-[#a0a39e]">07 / MORE PRIMITIVES</span><h3>
                    More essentials
                  </h3><p>
                    Native inputs and useful building blocks.
                  </p>
                </div><code>&lt;.radio&gt;</code>
              </div>
              <div class="demo rounded-2xl border border-[#e9eae7] bg-white p-[25px] dark:border-[#303230] dark:bg-[#1a1b1d]">
                <div class="demo-row flex flex-wrap items-center gap-2.5">
                  <.radio id="radio-one" name="plan" value="starter" checked>Starter</.radio><.radio
                    id="radio-two"
                    name="plan"
                    value="pro"
                  >
                    Pro
                  </.radio><.kbd>⌘ K</.kbd><.ui_link href="#top">Back to top</.ui_link>
                </div><div class="divider my-[27px] h-px bg-[#e9eae7] dark:bg-[#303230]"></div><label
                  for="preview-notes"
                  class="hui-label"
                >Notes</label><.textarea
                  id="preview-notes"
                  placeholder="Add a note…"
                  rows="3"
                />
              </div>
            </section>
            <section
              class="showcase mb-[54px] scroll-mt-[95px] [&_h3]:mt-[9px] [&_h3]:mb-[7px] [&_h3]:text-[23px] [&_h3]:tracking-[-.04em] [&_code]:whitespace-nowrap [&_code]:rounded-md [&_code]:bg-[#f3f4f1] [&_code]:px-[9px] [&_code]:py-[7px] [&_code]:text-[11px] [&_code]:text-[#73767a] dark:[&_code]:bg-[#222421] dark:[&_code]:text-[#a0a39e]"
              id="more-patterns"
            >
              <div class="showcase-title mb-[18px] flex items-start justify-between gap-3 max-[520px]:flex-wrap [&_p]:m-0 [&_p]:leading-[1.5] [&_p]:text-[#73767a] dark:[&_p]:text-[#a0a39e]">
                <div>
                  <span class="number text-[10px] font-bold tracking-[.1em] text-[#73767a] dark:text-[#a0a39e]">08 / PATTERNS</span><h3>
                    More components
                  </h3><p>
                    Selection, feedback, disclosure, and structured data.
                  </p>
                </div>
              </div>
              <div class="demo rounded-2xl border border-[#e9eae7] bg-white p-[25px] dark:border-[#303230] dark:bg-[#1a1b1d]">
                <label for="preview-select" class="hui-label">Plan</label><.select
                  id="preview-select"
                  options={[{"Starter", "starter"}, {"Pro", "pro"}]}
                  value="pro"
                />
                <div class="divider my-[27px] h-px bg-[#e9eae7] dark:bg-[#303230]"></div><.alert
                  title="Your changes are saved"
                  color="success"
                >
                  Your workspace is up to date.
                </.alert>
                <div class="divider my-[27px] h-px bg-[#e9eae7] dark:bg-[#303230]"></div><.accordion title="What is included?">
                  All the essentials to get started.
                </.accordion><.accordion title="Can I change my plan?">
                  You can update your plan at any time.
                </.accordion>
                <div class="divider my-[27px] h-px bg-[#e9eae7] dark:bg-[#303230]"></div><.data_table
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
              class="showcase mb-[54px] scroll-mt-[95px] [&_h3]:mt-[9px] [&_h3]:mb-[7px] [&_h3]:text-[23px] [&_h3]:tracking-[-.04em] [&_code]:whitespace-nowrap [&_code]:rounded-md [&_code]:bg-[#f3f4f1] [&_code]:px-[9px] [&_code]:py-[7px] [&_code]:text-[11px] [&_code]:text-[#73767a] dark:[&_code]:bg-[#222421] dark:[&_code]:text-[#a0a39e]"
              id="dialogs"
            >
              <div class="showcase-title mb-[18px] flex items-start justify-between gap-3 max-[520px]:flex-wrap [&_p]:m-0 [&_p]:leading-[1.5] [&_p]:text-[#73767a] dark:[&_p]:text-[#a0a39e]">
                <div>
                  <span class="number text-[10px] font-bold tracking-[.1em] text-[#73767a] dark:text-[#a0a39e]">09 / OVERLAY</span><h3>
                    Modal
                  </h3><p>
                    A focused space for a short task or message.
                  </p>
                </div><code>&lt;.modal&gt;</code>
              </div>
              <div class="demo rounded-2xl border border-[#e9eae7] bg-white p-[25px] dark:border-[#303230] dark:bg-[#1a1b1d]">
                <.button data-hero-dialog-open="preview-modal">Open modal</.button><.modal
                  id="preview-modal"
                  title="Edit profile"
                >
                  Update your profile details here.<:footer>
                    <.button variant="primary" disabled>Save changes</.button>
                  </:footer>
                </.modal>
              </div>
            </section>
            <footer class="flex justify-between gap-[15px] border-t border-[#e9eae7] pt-7 pb-10 text-[11px] text-[#73767a] dark:border-[#303230] dark:text-[#a0a39e] [&>span:first-child]:font-bold [&>span:first-child]:text-[#18191a] dark:[&>span:first-child]:text-[#f1f2ef] [&>span:nth-child(2)]:text-[9px] [&>span:nth-child(2)]:tracking-[.08em] max-[520px]:[&>span:nth-child(2)]:hidden">
              <span>✳&#xFE0E; &nbsp; HeroUI for LiveView</span><span>AN EARLY LOOK · MADE WITH PHOENIX</span><a href="#top">Back to top ↑</a>
            </footer>
          </main>
        </div>
        <script type="module">
          import { installHeroUI } from "/hero_ui.js?v=dropdown";
          import { registerHeroUIAlpine } from "/hero_ui_alpine.js";
          import Alpine from "/alpine.esm.js";
          import collapse from "/alpine-collapse.esm.js";
          window.Alpine = Alpine;
          Alpine.plugin(collapse);
          registerHeroUIAlpine(Alpine);
          Alpine.start();
          installHeroUI();
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

defmodule HeroUI.Preview.Router do
  use Plug.Router
  plug(:match)
  plug(:dispatch)

  get "/" do
    html = HeroUI.Preview.page(%{}) |> Phoenix.HTML.Safe.to_iodata()
    conn |> put_resp_content_type("text/html") |> send_resp(200, html)
  end

  get "/hero_ui.css" do
    conn
    |> put_resp_content_type("text/css")
    |> put_resp_header("cache-control", "no-store")
    |> send_resp(200, File.read!(Application.app_dir(:hero_ui, "priv/static/hero_ui.css")))
  end

  get "/avatar-demo.svg" do
    conn
    |> put_resp_content_type("image/svg+xml")
    |> send_resp(
      200,
      ~s(<svg xmlns="http://www.w3.org/2000/svg" width="40" height="40"><rect width="40" height="40" fill="#006fee"/></svg>)
    )
  end

  get "/select.js" do
    conn
    |> put_resp_content_type("text/javascript")
    |> send_resp(200, File.read!(Path.join([File.cwd!(), "assets", "js", "select.js"])))
  end

  get "/combo_box.js" do
    conn
    |> put_resp_content_type("text/javascript")
    |> send_resp(200, File.read!(Path.join([File.cwd!(), "assets", "js", "combo_box.js"])))
  end

  get "/color_field.js" do
    conn
    |> put_resp_content_type("text/javascript")
    |> send_resp(200, File.read!(Path.join([File.cwd!(), "assets", "js", "color_field.js"])))
  end

  get "/toast.js" do
    conn
    |> put_resp_content_type("text/javascript")
    |> send_resp(200, File.read!(Path.join([File.cwd!(), "assets", "js", "toast.js"])))
  end

  get "/date_picker.js" do
    conn
    |> put_resp_content_type("text/javascript")
    |> send_resp(200, File.read!(Path.join([File.cwd!(), "assets", "js", "date_picker.js"])))
  end

  get "/date_field.js" do
    conn
    |> put_resp_content_type("text/javascript")
    |> send_resp(200, File.read!(Path.join([File.cwd!(), "assets", "js", "date_field.js"])))
  end

  get "/time_field.js" do
    conn
    |> put_resp_content_type("text/javascript")
    |> send_resp(200, File.read!(Path.join([File.cwd!(), "assets", "js", "time_field.js"])))
  end

  get "/autocomplete.js" do
    conn
    |> put_resp_content_type("text/javascript")
    |> send_resp(200, File.read!(Path.join([File.cwd!(), "assets", "js", "autocomplete.js"])))
  end

  get "/sheet.js" do
    conn
    |> put_resp_content_type("text/javascript")
    |> send_resp(200, File.read!(Path.join([File.cwd!(), "assets", "js", "sheet.js"])))
  end

  get "/dropdown.js" do
    conn
    |> put_resp_content_type("text/javascript")
    |> send_resp(200, File.read!(Path.join([File.cwd!(), "assets", "js", "dropdown.js"])))
  end

  get "/calendar.js" do
    conn
    |> put_resp_content_type("text/javascript")
    |> send_resp(200, File.read!(Path.join([File.cwd!(), "assets", "js", "calendar.js"])))
  end

  get "/hero_ui_alpine.js" do
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

  get "/hero_ui.js" do
    conn
    |> put_resp_content_type("text/javascript")
    |> put_resp_header("cache-control", "no-store")
    |> send_resp(200, File.read!(Path.join([File.cwd!(), "assets", "js", "hero_ui.js"])))
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
  use Mix.Task
  @shortdoc "Starts the local component preview"
  def run(_) do
    Mix.Task.run("app.start")
    Tailwind.install_and_run(:preview, [])
    port = String.to_integer(System.get_env("PORT", "4000"))

    Application.put_env(:hero_ui, HeroUI.Preview.Endpoint,
      adapter: Bandit.PhoenixAdapter,
      http: [ip: {127, 0, 0, 1}, port: port],
      server: true,
      secret_key_base: String.duplicate("preview-secret-key-", 4),
      live_view: [signing_salt: "livepreview"],
      pubsub_server: HeroUI.Preview.PubSub
    )

    {:ok, _} =
      Phoenix.PubSub.Supervisor.start_link(
        name: HeroUI.Preview.PubSub,
        adapter: Phoenix.PubSub.PG2
      )

    {:ok, _} = HeroUI.Preview.Endpoint.start_link()
    Mix.shell().info("Preview available at http://localhost:#{port}")
    Process.sleep(:infinity)
  end
end
