# OlisUI for LiveView

OlisUI is an early-stage component library for Phoenix LiveView, built with Tailwind CSS v4 and Alpine.js. It includes form controls, navigation, overlays, feedback, tables, and more. APIs are still evolving.

## Try the preview

```sh
mix deps.get
npm ci
mix preview
```

Open [localhost:4000](http://localhost:4000) for the component gallery or [localhost:4000/live-preview](http://localhost:4000/live-preview) for LiveView examples. For a complete application, see the [admin dashboard example](https://github.com/gootik/olis_ui/tree/main/examples/admin).

## Install

Add OlisUI to your Phoenix app's `mix.exs`.

```elixir
{:olis_ui, "~> 0.1.0"}
```

Then run:

```sh
mix deps.get
mix olis_ui.install
cd assets
npm install --save-exact alpinejs@3.17.5 @alpinejs/collapse@3.17.5 tw-animate-css@1.4.0
```

In `assets/css/app.css`, replace the Tailwind import with:

```css
@import "./olis_ui.css";
```

In `assets/js/app.js`, start OlisUI before connecting your LiveSocket and add its DOM callback to the LiveSocket options:

```js
import { olisUI } from "./olis_ui";

olisUI.start();

// In your existing LiveSocket options:
dom: { onBeforeElUpdated: olisUI.beforeUpdate }
```

Restart your asset watcher. If your app already starts Alpine, follow the [manual Alpine setup](docs/reference.md#usage) instead.

## Use components

Call components directly to keep your existing Phoenix imports:

```heex
<OlisUI.Button.button phx-click="save">Save changes</OlisUI.Button.button>
<OlisUI.Forms.text_field field={@form[:email]} label="Email" type="email" />
```

To use the shorter `<.button>` syntax, import the component modules you need in your LiveView or HTML helpers:

```elixir
import OlisUI.Button
import OlisUI.Forms
```

Resolve any name conflicts with `CoreComponents`. See the [component reference](docs/reference.md) for module names, examples, and interactive behavior.

The default theme is light. Set `data-theme="dark"` on the document root for the dark palette.

## Development

After installing dependencies, run the checks with:

```sh
mix format --check-formatted
mix credo
mix test
npm run format:check
npm run lint
npm run lint:css
npm run test:js
```

## License

OlisUI is licensed under [Apache-2.0](LICENSE). See the [third-party notices](THIRD_PARTY_NOTICES.md) for bundled assets.
