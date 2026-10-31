# OlisUI foundation styles

`index.css` imports the local animation utilities, base styles, components, theme tokens, utilities, and variants in cascade order. Component styles are grouped by component; the default theme is in `themes/default`. Application-specific adjustments belong in `../olis_ui.css`.

These styles were adapted from upstream Apache-2.0 and MIT-licensed sources. See `THIRD_PARTY_NOTICES.md` and `LICENSES/` at the repository root for provenance and license texts. The local overlay animation names have been changed to the `olis-` prefix.

The Stylelint configuration retains a narrow set of formatting and compatibility exceptions for the imported foundation. In particular, the animation utilities contain repeated custom properties that Tailwind resolves as fallbacks, and some empty rules are reserved component states. The rest of the CSS lint rules still apply.
