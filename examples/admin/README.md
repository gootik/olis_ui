# OlisUI admin example

A standalone Phoenix LiveView commerce dashboard using the local OlisUI library. Explore orders, filter and sort the table, create an order, export the filtered results, edit settings, and try additional controls in the UI kit. Data is held in the LiveView session and resets on reload; no database or credentials are required.

From the repository root, install the JavaScript dependencies with `npm ci`. Then run:

```sh
cd examples/admin
mix deps.get
mix admin
```

Open <http://localhost:4001>. Set `PORT` to use another port. `mix admin` rebuilds the Tailwind stylesheet when it starts; restart it after changing styles or component markup. This example uses the repository's local JavaScript and CSS sources so it always demonstrates the checked-out library.

Run its Elixir tests with `mix test`. The dashboard and UI kit use every public OlisUI component, including lower-level compositional primitives. The main preview remains the reference for individual variants and states.
