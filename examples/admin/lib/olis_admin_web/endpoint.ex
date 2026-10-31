defmodule OlisAdminWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :olis_admin

  @session_options [store: :cookie, key: "_olis_admin_key", signing_salt: "admin-session"]
  @repo_root Path.expand("../../../..", __DIR__)

  socket("/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]],
    longpoll: false
  )

  plug(Plug.Static, at: "/assets", from: {:olis_admin, "priv/static"}, gzip: false)
  plug(Plug.Static, at: "/ui", from: Path.join(@repo_root, "assets/js"), gzip: false)
  plug(Plug.Static, at: "/vendor/phoenix", from: {:phoenix, "priv/static"}, gzip: false)

  plug(Plug.Static,
    at: "/vendor/liveview",
    from: {:phoenix_live_view, "priv/static"},
    gzip: false
  )

  plug(Plug.Static,
    at: "/vendor/alpine",
    from: Path.join(@repo_root, "node_modules/alpinejs/dist"),
    gzip: false
  )

  plug(Plug.Static,
    at: "/vendor/collapse",
    from: Path.join(@repo_root, "node_modules/@alpinejs/collapse/dist"),
    gzip: false
  )

  plug(Plug.Static,
    at: "/fonts",
    from: Path.join(@repo_root, "node_modules/@fontsource-variable/inter"),
    gzip: false
  )

  plug(Plug.RequestId)
  plug(Plug.Telemetry, event_prefix: [:phoenix, :endpoint])

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()
  )

  plug(Plug.MethodOverride)
  plug(Plug.Head)
  plug(Plug.Session, @session_options)
  plug(OlisAdminWeb.Router)
end
