import Config

config :tailwind,
  version: "4.1.10",
  path: Path.expand("../node_modules/.bin/tailwindcss", __DIR__),
  preview: [
    args: ~w(--input=assets/css/app.css --output=priv/static/hero_ui.css),
    cd: Path.expand("..", __DIR__)
  ]
