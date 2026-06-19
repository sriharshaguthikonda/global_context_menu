# Security review for 🤖 Text Router

This fork turns the plugin example app into a compact Android selected-text router.

## What it receives

Only the text that Android passes to the app through `Intent.ACTION_PROCESS_TEXT` when the user taps `🤖` in the selected-text toolbar.

## Permissions

The app manifest declares no dangerous permissions.

It does not request:

- `android.permission.INTERNET`
- storage permissions
- contacts permissions
- microphone permission
- camera permission
- accessibility service permission
- notification listener permission
- overlay permission

## Data flow

1. User selects text in another app.
2. Android launches `TextProcessorActivity` with `ACTION_PROCESS_TEXT`.
3. Flutter reads the selected text through the plugin.
4. User taps a router button.
5. Native Kotlin helper copies the selected text to clipboard and opens the chosen app or URL.

## Important limitation

This router app itself does not upload the selected text because it has no internet permission.

However, when you choose ChatGPT, Claude, Grok, Perplexity, Edge, Truecaller, or the Android share sheet, the target app may send that text to its own servers. That is outside this router app's control.

## Known Android limitation

The manifest uses `android:priority="999"` on the `ACTION_PROCESS_TEXT` intent filter to try to make `🤖` appear early. OEM Android builds can still apply their own toolbar sorting, so first position is best-effort, not guaranteed.
