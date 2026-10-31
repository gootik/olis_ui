import Config

config :olis_admin, OlisAdminWeb.Endpoint,
  adapter: Bandit.PhoenixAdapter,
  url: [host: "localhost"],
  render_errors: [formats: [html: OlisAdminWeb.ErrorHTML], layout: false],
  pubsub_server: OlisAdmin.PubSub,
  live_view: [signing_salt: "admin-demo"],
  secret_key_base: String.duplicate("olis-admin-demo-secret-", 4),
  server: config_env() != :test,
  http: [ip: {127, 0, 0, 1}, port: String.to_integer(System.get_env("PORT", "4001"))]

config :phoenix, :json_library, Jason
