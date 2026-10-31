defmodule HeroUI.Preview do
  use Phoenix.Component
  import HeroUI

  def page(assigns) do
    ~H"""
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <title>HeroUI for LiveView — Component preview</title>
        <link rel="stylesheet" href="/hero_ui.css" />
        <link rel="stylesheet" href="/preview.css" />
        <script>
          try { document.documentElement.dataset.theme = localStorage.getItem('preview-theme') || 'light'; } catch (_) {}
        </script>
      </head>
      <body>
        <header class="topbar">
          <a class="brand" href="#top"><span class="brand-mark">✳</span>
          HeroUI <span>for LiveView</span></a>
          <div class="top-actions">
            <span class="version">EARLY PREVIEW</span><button
              class="theme-toggle"
              type="button"
              id="theme-toggle"
              aria-label="Toggle color theme"
            >◐</button>
          </div>
        </header>
        <div class="layout" id="top">
          <aside class="sidebar">
            <p class="nav-label">EXPLORE</p>
            <a class="nav-current" href="#overview">Overview <span>↗</span></a>
            <p class="nav-label">COMPONENTS</p>
            <a href="#buttons">Button</a><a href="#inputs">Input</a><a href="#cards">Card</a><a href="#chips">Chip</a><a href="#controls">Controls</a><a href="#feedback">Feedback</a>
            <div class="sidebar-note">
              <span>✦</span><strong>Built for LiveView</strong><p>
                Familiar components, right in your HEEx templates.
              </p>
            </div>
          </aside>
          <main>
            <section class="intro" id="overview">
              <div class="eyebrow"><span></span> THE COMPONENT LIBRARY</div>
              <h1>Build something<br /><em>beautiful.</em></h1>
              <p>
                A first look at HeroUI-inspired components for Phoenix LiveView. Thoughtful defaults, flexible styling, and a little less boilerplate.
              </p>
              <div class="intro-actions">
                <a href="#buttons" class="intro-link">Explore components <span>↘</span></a><span class="intro-caption">DESIGNED FOR THE WAY YOU BUILD</span>
              </div>
            </section>
            <div class="section-heading">
              <div>
                <p class="overline">THE BUILDING BLOCKS</p><h2>Components <span>✳</span></h2>
              </div><p>A growing collection of essentials.<br />Explore the first five below.</p>
            </div>
            <section class="showcase" id="buttons">
              <div class="showcase-title">
                <div>
                  <span class="number">01 / ACTION</span><h3>Button</h3><p>
                    Give every action the right amount of emphasis.
                  </p>
                </div><code>&lt;.button&gt;</code>
              </div>
              <div class="demo">
                <div class="demo-label">VARIANTS <span>7 OPTIONS</span></div><div class="demo-row">
                  <.button>Primary</.button><.button variant="secondary">Secondary</.button><.button variant="tertiary">Tertiary</.button><.button variant="outline">Outline</.button><.button variant="ghost">Ghost</.button><.button variant="danger">Danger</.button><.button variant="danger-soft">Danger soft</.button>
                </div><div class="divider"></div><div class="demo-label">SIZES & STATES</div><div class="demo-row">
                  <.button size="sm">Small</.button><.button>Medium</.button><.button size="lg">Large</.button><.button disabled>Disabled</.button><.button
                    icon_only
                    aria-label="Add"
                  >+</.button>
                </div>
              </div>
            </section>
            <section class="showcase" id="inputs">
              <div class="showcase-title">
                <div>
                  <span class="number">02 / INPUT</span><h3>Input & text field</h3><p>
                    Clear, accessible inputs for the details that matter.
                  </p>
                </div><code>&lt;.text_field&gt;</code>
              </div>
              <div class="demo">
                <div class="demo-label">FORM FIELDS <span>LABELS & FEEDBACK</span></div><div class="fields">
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
            <div class="two-column">
              <section class="showcase" id="cards">
                <div class="showcase-title">
                  <div>
                    <span class="number">03 / LAYOUT</span><h3>Card</h3><p>
                      A home for related content.
                    </p>
                  </div><code>&lt;.card&gt;</code>
                </div><div class="demo card-demo">
                  <.card>
                    <div class="sample-card-top">
                      <span class="sample-icon">✳</span><.chip color="success" variant="soft">
                        Active
                      </.chip>
                    </div><h4>Everything in its place.</h4><p>
                      Bring your ideas together in a space that feels just right.
                    </p><.button variant="secondary" size="sm">View project ↗</.button>
                  </.card>
                </div>
              </section>
              <section class="showcase" id="chips">
                <div class="showcase-title">
                  <div>
                    <span class="number">04 / DISPLAY</span><h3>Chip</h3><p>
                      Small labels, useful context.
                    </p>
                  </div><code>&lt;.chip&gt;</code>
                </div><div class="demo chip-demo">
                  <div class="demo-label">STATUS & CATEGORY</div><div class="demo-row">
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
            <section class="showcase" id="controls">
              <div class="showcase-title">
                <div>
                  <span class="number">05 / INPUT</span><h3>Checkbox & switch</h3><p>
                    Native controls with clear selected and disabled states.
                  </p>
                </div><code>&lt;.checkbox&gt;</code>
              </div>
              <div class="demo">
                <div class="demo-row">
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
            <section class="showcase" id="feedback">
              <div class="showcase-title">
                <div>
                  <span class="number">06 / FEEDBACK</span><h3>Feedback & identity</h3><p>
                    Progress, loading, separators, and avatars.
                  </p>
                </div><code>&lt;.progress_bar&gt;</code>
              </div>
              <div class="demo">
                <div class="demo-row">
                  <.avatar name="Jane Doe" size="sm" /><.avatar name="Alex Kim" /><.avatar
                    name="Morgan Lee"
                    size="lg"
                  /><.spinner size="sm" /><.spinner /><.spinner size="lg" />
                </div><div class="divider"></div><.progress_bar label="Uploading" value={65} /><div class="divider">
                </div>
                <div class="demo-row">
                  <.progress_circle label="Uploading" value={65} size="sm" /><.progress_circle
                    label="Uploading"
                    value={65}
                  /><.progress_circle label="Uploading" value={65} size="lg" color="success" /><.progress_circle label="Loading" />
                </div>
                <div class="divider"></div><.meter
                  label="Storage"
                  value={42}
                  max={100}
                  value_text="42 GB of 100 GB"
                /><div class="divider"></div><.skeleton style="height: 16px; width: 70%;" /><div style="height: 12px">
                </div><.skeleton style="height: 16px; width: 45%;" /><div class="divider"></div><.separator />
              </div>
            </section>
            <section class="showcase" id="more-components">
              <div class="showcase-title">
                <div>
                  <span class="number">07 / MORE PRIMITIVES</span><h3>More essentials</h3><p>
                    Native inputs and useful building blocks.
                  </p>
                </div><code>&lt;.radio&gt;</code>
              </div>
              <div class="demo">
                <div class="demo-row">
                  <.radio id="radio-one" name="plan" value="starter" checked>Starter</.radio><.radio
                    id="radio-two"
                    name="plan"
                    value="pro"
                  >
                    Pro
                  </.radio><.kbd>⌘ K</.kbd><.ui_link href="#top">Back to top</.ui_link>
                </div><div class="divider"></div><label for="preview-notes" class="hui-label">Notes</label><.textarea
                  id="preview-notes"
                  placeholder="Add a note…"
                  rows="3"
                />
              </div>
            </section>
            <section class="showcase" id="more-patterns">
              <div class="showcase-title">
                <div>
                  <span class="number">08 / PATTERNS</span><h3>More components</h3><p>
                    Selection, feedback, disclosure, and structured data.
                  </p>
                </div>
              </div>
              <div class="demo">
                <label for="preview-select" class="hui-label">Plan</label><.select
                  id="preview-select"
                  options={[{"Starter", "starter"}, {"Pro", "pro"}]}
                  value="pro"
                />
                <div class="divider"></div><.alert title="Your changes are saved" color="success">
                  Your workspace is up to date.
                </.alert>
                <div class="divider"></div><.accordion title="What is included?">
                  All the essentials to get started.
                </.accordion><.accordion title="Can I change my plan?">
                  You can update your plan at any time.
                </.accordion>
                <div class="divider"></div><.data_table
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
            <section class="showcase" id="dialogs">
              <div class="showcase-title">
                <div>
                  <span class="number">09 / OVERLAY</span><h3>Modal</h3><p>
                    A focused space for a short task or message.
                  </p>
                </div><code>&lt;.modal&gt;</code>
              </div>
              <div class="demo">
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
            <footer>
              <span>✳ &nbsp; HeroUI for LiveView</span><span>AN EARLY LOOK · MADE WITH PHOENIX</span><a href="#top">Back to top ↑</a>
            </footer>
          </main>
        </div>
        <script type="module">
          import { installHeroUI } from "/hero_ui.js";
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

  get "/input_otp.js" do
    conn
    |> put_resp_content_type("text/javascript")
    |> send_resp(200, File.read!(Path.join([File.cwd!(), "assets", "js", "input_otp.js"])))
  end

  get "/tag_group.js" do
    conn
    |> put_resp_content_type("text/javascript")
    |> send_resp(200, File.read!(Path.join([File.cwd!(), "assets", "js", "tag_group.js"])))
  end

  get "/combo_box.js" do
    conn
    |> put_resp_content_type("text/javascript")
    |> send_resp(200, File.read!(Path.join([File.cwd!(), "assets", "js", "combo_box.js"])))
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

  get "/calendar.js" do
    conn
    |> put_resp_content_type("text/javascript")
    |> send_resp(200, File.read!(Path.join([File.cwd!(), "assets", "js", "calendar.js"])))
  end

  get "/hero_ui.js" do
    conn
    |> put_resp_content_type("text/javascript")
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

  get "/live-preview.css" do
    conn
    |> put_resp_content_type("text/css")
    |> send_resp(200, File.read!(Path.join([File.cwd!(), "preview", "live_preview.css"])))
  end

  get "/preview.css" do
    conn
    |> put_resp_content_type("text/css")
    |> send_resp(200, File.read!(Path.join([File.cwd!(), "preview", "preview.css"])))
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
